// On development

import 'dart:async';
import 'dart:collection';
import 'package:bson/bson.dart' show BsonLong;

import 'package:mongo_dart/src/database/operation/base/command_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/administration_commands/kill_cursors_command/kill_cursors_command.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/get_more_command/get_more_command.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/find_operation/find_operation.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import '../../../mongo_dart.dart';

typedef MonadicBlock = void Function(Map<String, dynamic> value);

class ModernCursor {
  ModernCursor(this.operation,
      {this.checksumPresent, this.moreToCome, this.exhaustAllowed})
      : collection = operation.collection,
        db = operation.collection?.db {
    if (collection == null) {
      throw MongoDartError('Collection required in cursor initialization');
    }
    if (operation is FindOperation) {
      tailable = (operation as FindOperation).isTailable;
      awaitData = (operation as FindOperation).isAwaitData;
    }
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
  ModernCursor.fromOpenId(this.collection, this.cursorId,
      {this.tailable,
      this.awaitData,
      this.checksumPresent,
      this.moreToCome,
      this.exhaustAllowed}) {
    state = State.OPEN;
    db = collection?.db;
    tailable ??= false;
    awaitData ??= false;
  }

  State state = State.INIT;
  BsonLong cursorId = BsonLong(0);
  Db db;
  Queue<Map<String, dynamic>> items = Queue<Map<String, Object>>();
  DbCollection collection;
  int _returnedCount = 0;
  bool tailable = false;
  bool awaitData = false;

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
  bool explain;
  bool checksumPresent;
  bool moreToCome;
  bool exhaustAllowed;

  /// The operation to be executed.
  /// It must be an operation that returns a cursorId, like find, getMore, etc.
  CommandOperation operation;

  /// Specify the milliseconds between getMore on tailable cursor,
  /// only applicable when awaitData isn't set.
  /// Default value is 100 ms
  int tailableRetryInterval = 100;

  Map<String, Object> _getNextItem() {
    _returnedCount++;
    return items.removeFirst();
  }

  void extractCursorData(Map<String, Object> operationReturnMap) {
    Map<String, Object> cursorMap = operationReturnMap[keyCursor];
    if (cursorMap == null) {
      throw MongoDartError('The operation type ${operation.runtimeType} '
          'does not return a cursor');
    }
    var documents = (cursorMap[keyNextBatch] ?? cursorMap[keyFirstBatch] ?? []);
    for (var doc in documents) {
      items.add(doc as Map<String, Object>);
    }
  }

  Future<Map<String, Object>> _serverSideCursorClose() async {
    if (tailable) {
      throw MongoDartError('Tailable Cursor closed by the server.');
    }
    await close();
    return null;
  }

  Future<Map<String, Object>> nextObject() async {
    if (items.isNotEmpty) {
      return _getNextItem();
    }

    Map<String, Object> result;
    if (state == State.INIT) {
      result = await operation.execute();
      state = State.OPEN;
    } else if (state == State.OPEN) {
      if (cursorId.data == 0) {
        return _serverSideCursorClose();
      }
      var command = GetMoreCommand(collection, cursorId);
      result = await command.execute();
    }
    if (result[keyOk] == 0.0) {
      await close();
      throw MongoDartError(result[keyErrmsg],
          mongoCode: result[keyCode], errorCodeName: result[keyCodeName]);
    }
    Map cursorMap = result[keyCursor];
    cursorId = cursorMap == null ? 0 : BsonLong(cursorMap[keyId] ?? 0);
    // The result map returns last records while setting cursorId to zero.
    extractCursorData(result);
    if (items.isNotEmpty) {
      return _getNextItem();
    }
    if (cursorId.data == 0) {
      return _serverSideCursorClose();
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
    if (cursorId.value != 0) {
      var command = KillCursorsCommand(collection, [cursorId]);
      await command.execute();
      cursorId = BsonLong(0);
    }
    return;
  }

  Stream<Map<String, dynamic>> get stream async* {
    var doc = await nextObject();
    //if (tailable) {
    while (state != State.CLOSED) {
      if (doc != null) {
        yield doc;
      }
      doc = await nextObject();
    }
    //  return;
    //}
    //while (doc != null) {
    //  yield doc;
    //  doc = await nextObject();
    //}
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

class AggregateCursor extends CommandCursor {
  List pipeline;
  Map<String, dynamic> cursorOptions;
  bool allowDiskUse;
  AggregateCursor(Db db, DbCollection collection, this.pipeline,
      this.cursorOptions, this.allowDiskUse)
      : super(db, collection, <String, dynamic>{});
  @override
  MongoModernMessage generateQueryMessage() {
    return DbCommand(
        db,
        DbCommand.SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT,
        0,
        -1,
        {
          'aggregate': collection.collectionName,
          'pipeline': pipeline,
          'cursor': cursorOptions,
          'allowDiskUse': allowDiskUse
        },
        null);
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
