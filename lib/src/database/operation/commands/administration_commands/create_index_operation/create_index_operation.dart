import 'package:mongo_dart/mongo_dart.dart' show Connection, Db, DbCollection;
import 'package:mongo_dart/src/database/operation/base/command_operation.dart';
import 'package:mongo_dart/src/database/operation/base/operation_base.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'create_index_options.dart';

const Set keysToOmit = <String>{
  'name',
  'key',
  'writeConcern',
  'w',
  'wtimeout',
  'j',
  'fsync',
  'readPreference',
  'session'
};

class CreateIndexOperation extends CommandOperation {
  Object fieldOrSpec;
  Map<String, Object> indexes;

  CreateIndexOperation(Db db, DbCollection collection, this.fieldOrSpec,
      CreateIndexOptions indexOptions,
      {Connection connection, Map<String, Object> rawOptions})
      : super(db, indexOptions?.options ?? rawOptions,
            collection: collection,
            aspect: Aspect.writeOperation,
            connection: connection) {
    var indexParameters = parseIndexOptions(fieldOrSpec);
    final indexName = /* options != null && */
        options[keyName] != null && options[keyName] is String
            ? options[keyName] as String
            : indexParameters[keyName] as String;
    indexes = {keyName: indexName, keyKey: indexParameters[keyFieldHash]};
    options.remove(keyName);
  }

  @override
  Map<String, Object> $buildCommand() {
    var indexes = this.indexes;

    // merge all options
    var added = <String>[];
    for (var optionName in options.keys) {
      if (!keysToOmit.contains(optionName)) {
        indexes[optionName] = options[optionName];
        added.add(optionName);
      }
    }
    for (var optionName in added) {
      options.remove(optionName);
    }

    // Create command, apply write concern to command
    return <String, Object>{
      keyCreateIndexes: collection.collectionName,
      keyCreateIndexesArgument: [indexes]
    };
  }
}

Map<String, Object> parseIndexOptions(Object fieldOrSpec) {
  var fieldHash = <String, Object>{};
  var indexes = [];
  var keys;

// Get all the fields accordingly
  if (fieldOrSpec is String) {
// 'type'
    indexes.add(_fieldIndexName(fieldOrSpec, '1'));
    fieldHash[fieldOrSpec] = 1;
  } else if (fieldOrSpec is List) {
    for (Object object in fieldOrSpec) {
      if (object is String) {
// [{location:'2d'}, 'type']
        indexes.add(_fieldIndexName(object, '1'));
        fieldHash[object] = 1;
      } else if (object is List) {
// [['location', '2d'],['type', 1]]
        indexes.add(
            _fieldIndexName(object[0] as String, (object[1] ?? '1') as String));
        fieldHash[object[0]] = object[1] ?? '1';
      } else if (object is Map) {
// [{location:'2d'}, {type:1}]
        keys = object.keys;
        for (String key in keys) {
          indexes.add(_fieldIndexName(key, object[key] as String));
          fieldHash[key] = object[key];
        }
      } else {
// undefined (ignore)
      }
    }
  } else if (fieldOrSpec is Map) {
// {location:'2d', type:1}
    keys = fieldOrSpec.keys;
    for (String key in keys) {
      var indexDirection = '${fieldOrSpec[key]}';
      indexes.add(_fieldIndexName(key, indexDirection));
      fieldHash[key] = fieldOrSpec[key];
    }
  }

  return {keyName: indexes.join('_'), 'keys': keys, keyFieldHash: fieldHash};
}

String _fieldIndexName(String fieldName, String sort) => '${fieldName}_$sort';
