import 'package:mongo_dart/mongo_dart.dart'
    show Bulk, MongoCollection, WriteConcern, keyOrdered;
import 'package:mongo_dart/src/command/base/operation_base.dart';

import 'bulk_options.dart';

base class OrderedBulk extends Bulk {
  OrderedBulk(MongoCollection collection,
      {WriteConcern? writeConcern,
      Map<String, Object>? rawOptions,
      bool? bypassDocumentValidation})
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
  List<Command> commands = <Command>[];

  /// this contains the original command reference
  /// stored as pairs made of {
  ///   <startingIndexInsideThe corresponding commands element>:
  ///       <originaInputIndex>
  ///    }
  /// [{0: 0, 1: 1, 3:2}, {0: 3}]
  List<Map<int, int>> commandsOrigin = <Map<int, int>>[];

  @override
  List<Command> getBulkCommands() =>
      <Command>[for (var command in commands) ...splitCommands(command)];

  @override
  List<Map<int, int>> getBulkInputOrigins() => <Map<int, int>>[
        for (var i = 0; i < commandsOrigin.length; i++)
          ...splitInputOrigins(commandsOrigin[i],
              (commands[i].values.toList()[1] as List).length)
      ];

  @override
  void addCommand(Command command) {
    if (commands.isEmpty) {
      commands.add(command);
      commandsOrigin.add({0: operationInputIndex++});
      return;
    }
    var commandKey = command.keys.first;
    var lastCommandKey = commands.last.keys.first;
    if (commandKey == lastCommandKey) {
      var commandValue =
          command.values.toList()[1] as List<Map<String, dynamic>>;
      var lastCommandValues =
          commands.last.values.toList()[1] as List<Map<String, dynamic>>;
      commandsOrigin.last[lastCommandValues.length] = operationInputIndex++;
      lastCommandValues.addAll(commandValue);
    } else {
      commands.add(command);
      commandsOrigin.add({0: operationInputIndex++});
    }
  }
}
