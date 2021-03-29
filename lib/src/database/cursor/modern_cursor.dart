// On development

import 'dart:async';
import 'dart:collection';
import 'package:bson/bson.dart' show BsonLong;

import 'package:mongo_dart/src/database/commands/base/command_operation.dart';
import 'package:mongo_dart/src/database/commands/administration_commands/kill_cursors_command/kill_cursors_command.dart';
import 'package:mongo_dart/src/database/commands/aggreagation_commands/aggregate/return_classes/change_event.dart';
import 'package:mongo_dart/src/database/commands/aggreagation_commands/wrapper/change_stream/change_stream_handler.dart';
import 'package:mongo_dart/src/database/commands/aggreagation_commands/wrapper/change_stream/change_stream_operation.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/get_more_command/get_more_command.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/find_operation/find_operation.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/get_more_command/get_more_options.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import '../../../mongo_dart.dart';

typedef MonadicBlock = void Function(Map<String, dynamic> value);

const defaultBatchSize = 101;

class ModernCursor {
  ModernCursor(CommandOperation operation,
      {bool? checksumPresent,
      bool? moreToCome,
      bool? exhaustAllowed,
      int? batchSize})
      : operation = operation,
        collection = operation.collection,
        db = operation.collection?.db ?? operation.db,
        checksumPresent = checksumPresent ?? false,
        moreToCome = moreToCome ?? false,
        exhaustAllowed = exhaustAllowed ?? false {
    if (operation is FindOperation && collection == null) {
      throw MongoDartError('Collection required in cursor initialization');
    }
    if (operation is FindOperation) {
      tailable = (operation).isTailable;
      awaitData = (operation).isAwaitData;
    } else if (operation is ChangeStreamOperation) {
      isChangeStream = tailable = awaitData = true;
    }
    var internalBatchSize = batchSize;
    if (internalBatchSize == null) {
      var operationBatchSize = operation.options[keyBatchSize] as int?;
      if (operationBatchSize != null && operationBatchSize != 0) {
        internalBatchSize = operationBatchSize;
      }
    }

    _batchSize = internalBatchSize ?? defaultBatchSize;
  }

  /// This method allows the creation of the cursor from the Id and the
  /// collection. It is not intended for everyday use, but more for debugging
  /// and testing.
  ///
  /// All optional data must be correct or the result will be unpredictable.
  ///
  /// If another cursor already has been created with the same Id
  /// unpredictable results can be returned.
  ///
  /// The goal of this constructor is to build a cursor when a FindOperation
  /// or other read operation has been executed, without generating
  /// an explicit cursor. This way, for getting the extra documents,
  /// we may need a cursor.
  ModernCursor.fromOpenId(DbCollection collection, this.cursorId,
      {bool? tailable,
      bool? awaitData,
      bool? isChangeStream,
      bool? checksumPresent,
      bool? moreToCome,
      bool? exhaustAllowed})
      : collection = collection,
        collectionName = collection.collectionName,
        tailable = tailable ?? false,
        awaitData = awaitData ?? false,
        isChangeStream = isChangeStream ?? false,
        checksumPresent = checksumPresent ?? false,
        moreToCome = moreToCome ?? false,
        exhaustAllowed = exhaustAllowed ?? false {
    state = State.OPEN;
    db = collection.db;
    if (this.isChangeStream) {
      this.tailable = this.awaitData = true;
    }
    _batchSize = defaultBatchSize;
  }

  State state = State.INIT;
  BsonLong cursorId = BsonLong(0);
  late Db db;
  Queue<Map<String, Object?>> items = Queue<Map<String, Object?>>();
  DbCollection? collection;
  bool tailable = false;
  bool awaitData = false;
  bool isChangeStream = false;

  // Batch size for the getMore command if different from the default
  late int _batchSize;
  int get batchSize => _batchSize;
  set batchSize(int _value) {
    if (_value < 0) {
      throw MongoDartError('Batch size must be a non negative value');
    }
    _batchSize = _value;
  }

  // in case of collection agnostic commands (aggregate) is the name
  // of the collecton as returns from the first batch (taken from ns)
  String? collectionName;

  // at present you have to se these values on the operation options
  /* Map<String, dynamic> selector;
  Map<String, dynamic> fields;
  int skip = 0;
  int limit = 0;
  Map<String, dynamic> sort;
  Map<String, dynamic> hint; */
  //MonadicBlock eachCallback;
  //var eachComplete;

  // These 4 fields are not used at present
  bool explain = false;
  bool checksumPresent;
  bool moreToCome;
  bool exhaustAllowed;

  /// The operation to be executed.
  /// It must be an operation that returns a cursorId, like find, getMore, etc.
  CommandOperation? operation;

  /// Specify the milliseconds between getMore on tailable cursor,
  /// only applicable when awaitData isn't set.
  /// Default value is 100 ms
  int tailableRetryInterval = 100;

  Map<String, Object?>? _getNextItem() => items.removeFirst();

  void extractCursorData(Map<String, Object?> operationReturnMap) {
    if (operationReturnMap[keyCursor] == null) {
      throw MongoDartError('The operation type ${operation.runtimeType} '
          'does not return a cursor');
    }
    var cursorMap = operationReturnMap[keyCursor] as Map<String, Object?>?;
    if (cursorMap == null) {
      throw MongoDartError('No cursor returned');
    }
    if (collectionName == null && cursorMap[keyNs] != null) {
      var ns = cursorMap[keyNs] as String;
      var nsParts = ns.split('.');
      nsParts.removeAt(0);
      collectionName = nsParts.join('.');
    }
    List<Map<String, Object?>> documents;
    if (cursorMap[keyNextBatch] != null && cursorMap[keyNextBatch] is List) {
      documents = <Map<String, Object?>>[...cursorMap[keyNextBatch] as List];
    } else if (cursorMap[keyFirstBatch] != null &&
        cursorMap[keyFirstBatch] is List) {
      documents = <Map<String, Object?>>[...cursorMap[keyFirstBatch] as List];
    } else {
      documents = <Map<String, Object?>>[];
    }

    for (var doc in documents) {
      items.add(doc);
    }
  }

  Future<void> _serverSideCursorClose() async {
    if (tailable) {
      throw MongoDartError('Tailable Cursor closed by the server.');
    }
    return close();
  }

  /// Returns only the first document (if any) and then closes the cursor
  ///
  /// Convenience method for
  /// ```dart
  /// await nextObject();
  /// await close();
  /// ```
  Future<Map<String, Object?>?> onlyFirst() async {
    var ret = await nextObject();
    await close();
    return ret;
  }

  Future<Map<String, Object?>?> nextObject() async {
    if (items.isNotEmpty) {
      return _getNextItem();
    }

    var justPrepareCursor = false;
    Map<String, Object?>? result;
    if (state == State.INIT && operation != null) {
      if (operation!.options[keyBatchSize] != null &&
          operation!.options[keyBatchSize] == 0) {
        justPrepareCursor = true;
      }
      result = await operation!.execute();
      state = State.OPEN;
    } else if (state == State.OPEN) {
      if (cursorId.data == 0) {
        await _serverSideCursorClose();
        return null;
      }
      var command = GetMoreCommand(collection, cursorId,
          db: db,
          collectionName: collectionName,
          getMoreOptions: GetMoreOptions(batchSize: _batchSize));
      result = await command.execute();
    }
    if (result == null) {
      throw MongoDartError('Could not execut a further search');
    }
    if (result[keyOk] == 0.0) {
      await close();
      throw MongoDartError(
          result[keyErrmsg] as String? ??
              'Generic error in nextObject() method',
          mongoCode: result[keyCode] as int?,
          errorCodeName: result[keyCodeName] as String?);
    }
    var cursorMap = result[keyCursor] as Map<String, dynamic>?;
    cursorId =
        cursorMap == null ? BsonLong(0) : BsonLong(cursorMap[keyId] ?? 0);
    // The result map returns last records while setting cursorId to zero.
    extractCursorData(result);
    // batch size for "first batch" was 0, no data returned.
    // Just prepared the cursor for further fetching
    if (justPrepareCursor) {
      return nextObject();
    }
    if (items.isNotEmpty) {
      return _getNextItem();
    }
    if (cursorId.data == 0) {
      await _serverSideCursorClose();
      return null;
    }

    if (tailable) {
      if (awaitData) {
        return null;
      }
      return Future.delayed(
          Duration(milliseconds: tailableRetryInterval), () => null);
    }
    // residual check, it should never pass here.
    await close();
    return null;
  }

  Future<void> close() async {
    ////_log.finer("Closing cursor, cursorId = $cursorId");
    state = State.CLOSED;
    if (cursorId.value != 0 && collection != null) {
      var command = KillCursorsCommand(collection!, [cursorId], db: db);
      await command.execute();
      cursorId = BsonLong(0);
    }
    return;
  }

  Stream<Map<String, Object?>> get stream {
    var paused = true;
    var controller = StreamController<Map<String, Object?>>();

    Future<void> readNext() async {
      try {
        do {
          var doc = await nextObject();
          if (doc != null) {
            controller.add(doc);
          }
        } while (state != State.CLOSED && !paused);
        if (state == State.CLOSED) {
          await controller.close();
        }
      } catch (e) {
        controller.addError(e);
      }
    }

    void startReading() {
      if (state == State.CLOSED) {
        return;
      }
      paused = false;
      readNext();
    }

    void pauseReading() => paused = true;
    void resumeReading() => startReading();
    void cancelReading() async => await close();

    controller.onCancel = cancelReading;
    controller.onResume = resumeReading;
    controller.onPause = pauseReading;
    controller.onListen = startReading;

    return controller.stream;
  }

  Stream<ChangeEvent> get changeStream {
    if (!isChangeStream) {
      throw MongoDartError('Please, use this stream only for changeStreams');
    }
    return stream.transform(ChangeStreamHandler().transformer);
  }
}

/* 
class CommandCursor extends CursorModern {
  CommandCursor(Db db, DbCollection collection, selectorBuilderOrMap)
      : super(db, collection, selectorBuilderOrMap);
  bool firstBatch = true;
  @override
  MongoModernMessage generateQueryMessage() {
    throw UnimplementedError();
  }

  @override
  void getCursorData(MongoModernMessage replyMessage) {
    if (firstBatch) {
      firstBatch = false;
      var cursorMap = replyMessage.documents.first['cursor'];
      if (cursorMap != null) {
        cursorId = cursorMap['id'] as int;
        final firstBatch = cursorMap['firstBatch'] as List;
        items.addAll(List.from(firstBatch));
      }
    } else {
      super.getCursorData(replyMessage);
    }
  }
}

class ListCollectionsCursor extends CommandCursor {
  ListCollectionsCursor(Db db, selector) : super(db, null, selector);
  @override
  MongoModernMessage generateQueryMessage() {
    return DbCommand(
        db,
        DbCommand.SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT,
        0,
        -1,
        {'listCollections': 1, 'filter': selector},
        null);
  }
}

class ListIndexesCursor extends CommandCursor {
  ListIndexesCursor(Db db, DbCollection collection)
      : super(db, collection, <String, dynamic>{});
  @override
  MongoModernMessage generateQueryMessage() {
    return DbCommand(
        db,
        DbCommand.SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT,
        0,
        -1,
        {'listIndexes': collection.collectionName},
        null);
  }
}
 */
