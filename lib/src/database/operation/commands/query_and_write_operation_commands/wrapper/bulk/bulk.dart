import 'dart:math';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/message/mongo_modern_message.dart';
import 'package:mongo_dart/src/database/operation/commands/base/command_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/base/operation_base.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/return_classes/abstract_write_result.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/return_classes/bulk_write_result.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/delete_many/delete_many_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/delete_many/delete_many_statement.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/delete_one/delete_one_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/delete_one/delete_one_statement.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/insert_many/insert_many_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/insert_one/insert_one_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/replace_one/replace_one_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/wrapper/replace_one/replace_one_statement.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'bulk_options.dart';

abstract class Bulk extends CommandOperation {
  Bulk(DbCollection collection,
      {BulkOptions bulkOptions, Map<String, Object> rawOptions})
      : super(
            collection.db,
            <String, Object>{
              ...?bulkOptions?.getOptions(collection.db),
              ...?rawOptions
            },
            collection: collection,
            aspect: Aspect.writeOperation);

  List overallDocuments = <Map<String, Object>>[];
  List ids = [];

  void insertOne(Map<String, Object> document) {
    document[key_id] ??= ObjectId();
    ids.add(document[key_id]);
    overallDocuments.add(document);
    _setCommand(InsertOneOperation(collection, document));
  }

  void insertMany(List<Map<String, Object>> documents) {
    for (var document in documents) {
      document[key_id] ??= ObjectId();
      ids.add(document[key_id]);
      overallDocuments.add(document);
    }
    _setCommand(InsertManyOperation(collection, documents));
  }

  void deleteOne(DeleteOneStatement deleteRequest) =>
      _setCommand(DeleteOneOperation(collection, deleteRequest));

  void deleteMany(DeleteManyStatement deleteRequest) =>
      _setCommand(DeleteManyOperation(collection, deleteRequest));

  void replaceOne(ReplaceOneStatement replaceRequest) =>
      _setCommand(ReplaceOneOperation(collection, replaceRequest));

  void updateOne(UpdateOneStatement updateRequest) =>
      _setCommand(UpdateOneOperation(collection, updateRequest));

  void updateMany(UpdateManyStatement updateRequest) =>
      _setCommand(UpdateManyOperation(collection, updateRequest));

  void _setCommand(CommandOperation operation) =>
      addCommand(operation.$buildCommand());

  void addCommand(Map<String, Object> command);

  List<Map<String, Object>> getBulkCommands();

  @override
  Future<Map<String, Object>> execute() =>
      throw StateError('Call executeBulk() for bulk operations');
  @override
  Map<String, Object> $buildCommand() =>
      throw StateError('Call getBulkCommands() for bulk operations');

  Future<List<Map<String, Object>>> executeBulk() async {
    var retList = <Map<String, Object>>[];
    bool isOrdered = options[keyOrdered] ?? true;
    final db = this.db;
    if (db.state != State.OPEN) {
      throw MongoDartError('Db is in the wrong state: ${db.state}');
    }
    //final options = Map.from(this.options);

    // Todo implement topology
    // Did the user destroy the topology
    /*if (db?.serverConfig?.isDestroyed() ?? false) {
      return callback(MongoDartError('topology was destroyed'));
    }*/

    var commands = getBulkCommands();
    var saveOptions = Map<String, Object>.from(options);

    for (var command in commands) {
      processOptions(command);
      command.addAll(options);

      if (readPreference != null) {
        // search for the right connection
      }

      // Todo remove debug()
      //print(command);
      var modernMessage = MongoModernMessage(command);

      var ret =
          await db.executeModernMessage(modernMessage, connection: connection);
      ret['commandType'] = command.keys.first;
      retList.add(ret);
      if (isOrdered) {
        if (ret[keyOk] == 0.0 ||
            ret.containsKey(keyWriteErrors) ||
            ret.containsKey(keyWriteConcernError)) {
          return retList;
        }
      }

      options = Map<String, Object>.from(saveOptions);
    }
    return retList;
  }

  Future<BulkWriteResult> executeDocument() async {
    var executionRetList = await executeBulk();
    BulkWriteResult ret;
    WriteCommandType writeCommandType;

    for (var executionMap in executionRetList) {
      switch (executionMap['commandType']) {
        case keyInsert:
          writeCommandType = WriteCommandType.insert;
          break;
        case keyUpdate:
          writeCommandType = WriteCommandType.update;

          break;
        case keyDelete:
          writeCommandType = WriteCommandType.delete;

          break;
        default:
          throw StateError('Unknown command type');
      }
      if (ret == null) {
        ret = BulkWriteResult.fromMap(writeCommandType, executionMap);
      } else {
        ret.mergeFromMap(writeCommandType, executionMap);
      }
    }
    return ret;
    /* return BulkWriteResult.fromMap(WriteCommandType.insert, ret)
      ..ids = ids
      ..documents = overallDocuments; */
  }

  /// Split the command if the number of documents exceed the maxWriteBatchSixe
  ///
  /// Here we assume that the command is made this way:
  /// { <commandType>: <collectionName>, <commandArgument> : <documentsList>, 
  /// ...maybe others}
  List<Map<String, Object>> splitCommands(Map<String, Object> command) {
    var ret = <Map<String, Object>>[];
    if (command.isEmpty) {
      return ret;
    }
    var maxWriteBatchSize = MongoModernMessage.maxWriteBatchSize;
    var documentsNum = (command.values.toList()[1] as List).length;
    if (documentsNum <= maxWriteBatchSize) {
      ret.add(command);
    } else {
      var documents = command.values.toList()[1] as List;
      var offset = 0;
      var endSubList = maxWriteBatchSize;
      var rest = documentsNum;
      Map<String, Object> splittedDocument;
      while (rest > 0) {
        splittedDocument = Map.from(command);
        splittedDocument[command.keys.last] =
            documents.sublist(offset, endSubList);
        ret.add(splittedDocument);
        rest = documentsNum - endSubList;
        offset = endSubList;
        endSubList += min(rest, maxWriteBatchSize);
      }
    }
    return ret;
  }
}
