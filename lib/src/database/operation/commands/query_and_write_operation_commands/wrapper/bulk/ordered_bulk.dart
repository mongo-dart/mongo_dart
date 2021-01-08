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

  List<Map<String, Object>> commands = <Map<String, Object>>[];

  @override
  List<Map<String, Object>> getBulkCommands() => <Map<String, Object>>[
        for (var command in commands) ...splitCommands(command)
      ];

  @override
  void addCommand(Map<String, Object> command) {
    if (commands.isEmpty) {
      commands.add(command);
      return;
    }
    var commandKey = command.keys.first;
    var lastCommandKey = commands.last.keys.first;
    if (commandKey == lastCommandKey) {
      var commandValue = command.values.last;
      List lastCommandValues = commands.last.values.last;
      lastCommandValues.addAll(commandValue);
    } else {
      commands.add(command);
    }
  }
}
