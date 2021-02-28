import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'bulk.dart';
import 'bulk_options.dart';

class OrderedBulk extends Bulk {
  OrderedBulk(DbCollection collection,
      {WriteConcern writeConcern,
      Map<String, Object> rawOptions,
      bool bypassDocumentValidation})
      : super(collection,
            bulkOptions: BulkOptions(
                writeConcern: writeConcern,
                ordered: true,
                bypassDocumentValidation: bypassDocumentValidation),
            rawOptions:
                (rawOptions == null) ? null : (rawOptions..remove(keyOrdered)));

  /// This List contains the commands. Ex.
  /// [
  ///  {'insert': 'abc', 'documents': [{'a', 1}, {'a', 2}, {'a', 3}, {'a', 4}]}
  ///  {'delete': 'abc', 'deletes': [{'filter': {'a': 1}}]}
  /// ]
  /// This could be the result of the following:
  /// collection.bulkWrite([
  ///   {'insertOne': {'document: {'a', 1}}},
  ///   {'insertMany': {'documents': [{'a', 2}, {'a', 3}]}},
  ///   {'insertOne': {'document: {'a', 4}}},
  ///   {'deleteOne': {'filter': {'a': 1}}}
  /// ])
  List<Map<String, Object>> commands = <Map<String, Object>>[];

  /// this contains the original command reference
  /// stored as pairs made of {
  ///   <startingIndexInsideThe corresponding commands element>:
  ///       <originaInputIndex>
  ///    }
  /// [{0: 0, 1: 1, 3:2}, {0: 3}]
  List<Map<int, int>> commandsOrigin = <Map<int, int>>[];

  @override
  List<Map<String, Object>> getBulkCommands() => <Map<String, Object>>[
        for (var command in commands) ...splitCommands(command)
      ];

  @override
  List<Map<int, int>> getBulkInputOrigins() => <Map<int, int>>[
        for (var i = 0; i < commandsOrigin.length; i++)
          ...splitInputOrigins(commandsOrigin[i],
              (commands[i].values.toList()[1] as List).length)
      ];

  @override
  void addCommand(Map<String, Object> command) {
    if (commands.isEmpty) {
      commands.add(command);
      commandsOrigin.add({0: operationInputIndex++});
      return;
    }
    var commandKey = command.keys.first;
    var lastCommandKey = commands.last.keys.first;
    if (commandKey == lastCommandKey) {
      var commandValue = command.values.toList()[1];
      List lastCommandValues = commands.last.values.toList()[1];
      commandsOrigin.last[lastCommandValues.length] = operationInputIndex++;
      lastCommandValues.addAll(commandValue);
    } else {
      commands.add(command);
      commandsOrigin.add({0: operationInputIndex++});
    }
  }
}
