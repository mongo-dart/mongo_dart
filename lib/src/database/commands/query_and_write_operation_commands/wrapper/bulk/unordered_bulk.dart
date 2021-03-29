import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'bulk.dart';
import 'bulk_options.dart';

class UnorderedBulk extends Bulk {
  UnorderedBulk(DbCollection collection,
      {WriteConcern writeConcern,
      Map<String, Object> rawOptions,
      bool bypassDocumentValidation})
      : super(collection,
            bulkOptions: BulkOptions(
                writeConcern: writeConcern,
                ordered: false,
                bypassDocumentValidation: bypassDocumentValidation),
            rawOptions:
                (rawOptions == null) ? null : (rawOptions..remove(keyOrdered)));

  /// This Map contains the insert commands. Ex.
  /// {'insert': 'abc', 'documents': [{'a', 1}, {'a', 2}, {'a', 3}, {'a', 4}]}
  /// This could be the result of the following:
  /// collection.bulkWrite([
  ///   {'insertOne': {'document: {'a', 1}}},
  ///   {'insertMany': {'documents': [{'a', 2}, {'a', 3}]}},
  ///   {'deleteOne': {'filter': {'a': 1}}}
  ///   {'updateOne': {'filter': {'a': 1}, 'update': {'a': 10}}}
  ///   {'insertOne': {'document: {'a', 4}}},
  /// ])
  Map<String, Object> insertCommand = <String, Object>{};

  /// this contains the original insert command reference
  /// stored as pairs made of {<originaInputIndex>:
  ///    <startingIndexInsideThe corresponding commands element>}
  /// {0: 0, 1: 1, 3:4}
  Map<int, int> insertCommandsOrigin = <int, int>{};

  /// This Map contains the delete commands. Ex.
  /// {'delete': 'abc', 'deletes': [{'filter': {'a': 1}}]}
  /// This could be the result of the following:
  /// collection.bulkWrite([
  ///   {'insertOne': {'document: {'a', 1}}},
  ///   {'insertMany': {'documents': [{'a', 2}, {'a', 3}]}},
  ///   {'deleteOne': {'filter': {'a': 1}}}
  ///   {'updateOne': {'filter': {'a': 1}, 'update': {'a': 10}}}
  ///   {'insertOne': {'document: {'a', 4}}},
  /// ])
  Map<String, Object> deleteCommand = <String, Object>{};

  /// this contains the original delete command reference
  /// stored as pairs made of {<originaInputIndex>:
  ///    <startingIndexInsideThe corresponding commands element>}
  /// {0: 2}
  Map<int, int> deleteCommandsOrigin = <int, int>{};

  /// This Map contains the update commands. Ex.
  /// {'update': 'abc', 'updates': [{'filter': {'a': 1}, 'update': {'a': 10}}]}
  /// This could be the result of the following:
  /// collection.bulkWrite([
  ///   {'insertOne': {'document: {'a', 1}}},
  ///   {'insertMany': {'documents': [{'a', 2}, {'a', 3}]}},
  ///   {'deleteOne': {'filter': {'a': 1}}}
  ///   {'updateOne': {'filter': {'a': 1}, 'update': {'a': 10}}}
  ///   {'insertOne': {'document: {'a', 4}}},
  /// ])
  Map<String, Object> updateCommand = <String, Object>{};

  /// this contains the original update command reference
  /// stored as pairs made of {<originaInputIndex>:
  ///    <startingIndexInsideThe corresponding commands element>}
  /// {0: 3}
  Map<int, int> updateCommandsOrigin = <int, int>{};

  @override
  List<Map<String, Object>> getBulkCommands() => [
        if (insertCommand.isNotEmpty) ...splitCommands(insertCommand),
        if (updateCommand.isNotEmpty) ...splitCommands(updateCommand),
        if (deleteCommand.isNotEmpty) ...splitCommands(deleteCommand)
      ];

  @override
  void addCommand(Map<String, Object> command) {
    var commandKey = command.keys.first;
    List lastCommandValues;
    switch (commandKey) {
      case keyInsert:
        if (insertCommand.isEmpty) {
          insertCommand = command;
          insertCommandsOrigin[0] = operationInputIndex++;
          return;
        }
        lastCommandValues = insertCommand.values.toList()[1];
        insertCommandsOrigin[lastCommandValues.length] = operationInputIndex++;
        break;
      case keyDelete:
        if (deleteCommand.isEmpty) {
          deleteCommand = command;
          deleteCommandsOrigin[0] = operationInputIndex++;
          return;
        }
        lastCommandValues = deleteCommand.values.toList()[1];
        deleteCommandsOrigin[lastCommandValues.length] = operationInputIndex++;
        break;
      case keyUpdate:
        if (updateCommand.isEmpty) {
          updateCommand = command;
          updateCommandsOrigin[0] = operationInputIndex++;
          return;
        }
        lastCommandValues = updateCommand.values.toList()[1];
        updateCommandsOrigin[lastCommandValues.length] = operationInputIndex++;
        break;
    }
    var commandValue = command.values.toList()[1];
    lastCommandValues.addAll(commandValue);
  }

  @override
  List<Map<int, int>> getBulkInputOrigins() => <Map<int, int>>[
        if (insertCommand[keyInsertArgument] != null &&
            (insertCommand[keyInsertArgument] as List).isNotEmpty)
          ...splitInputOrigins(insertCommandsOrigin,
              (insertCommand[keyInsertArgument] as List).length),
        if (updateCommand[keyUpdateArgument] != null &&
            (updateCommand[keyUpdateArgument] as List).isNotEmpty)
          ...splitInputOrigins(updateCommandsOrigin,
              (updateCommand[keyUpdateArgument] as List).length),
        if (deleteCommand[keyDeleteArgument] != null &&
            (deleteCommand[keyDeleteArgument] as List).isNotEmpty)
          ...splitInputOrigins(deleteCommandsOrigin,
              (deleteCommand[keyDeleteArgument] as List).length),
      ];
}
