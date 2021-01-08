import 'dart:math';

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

  Map<String, Object> insertCommand = <String, Object>{};
  Map<String, Object> deleteCommand = <String, Object>{};

  @override
  List<Map<String, Object>> getBulkCommands() => [
        if (insertCommand.isNotEmpty) ...splitCommands(insertCommand),
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
          return;
        }
        lastCommandValues = insertCommand.values.last;
        break;
      case keyDelete:
        if (deleteCommand.isEmpty) {
          deleteCommand = command;
          return;
        }
        lastCommandValues = deleteCommand.values.last;
        break;
    }
    var commandValue = command.values.last;
    lastCommandValues.addAll(commandValue);
  }
}
