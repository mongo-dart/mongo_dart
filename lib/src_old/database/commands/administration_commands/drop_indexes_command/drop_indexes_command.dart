import 'package:mongo_dart/mongo_dart_old.dart' show Db, DbCollection;
import 'package:mongo_dart/src_old/database/commands/base/command_operation.dart';
import 'package:mongo_dart/src_old/database/commands/base/operation_base.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

import '../../../../../src/core/error/mongo_dart_error.dart';
import '../../../../network/connection.dart';
import 'drop_indexes_options.dart';

class DropIndexesCommand extends CommandOperation {
  Object index;
  late Map<String, Object> indexes;

  DropIndexesCommand(Db db, DbCollection collection, this.index,
      {DropIndexesOptions? dropIndexesOptions,
      Connection? connection,
      Map<String, Object>? rawOptions})
      : super(
            db,
            <String, Object>{
              ...?dropIndexesOptions?.getOptions(collection),
              ...?rawOptions
            },
            collection: collection,
            aspect: Aspect.writeOperation,
            connection: connection) {
    if (index is! String && index is! List<String> && index is! Map) {
      throw MongoDartError(
          'The index parameter is not String or List of string or an array');
    }
  }

  @override
  Map<String, Object> $buildCommand() {
    return <String, Object>{
      keyDropIndexes: collection!.collectionName,
      keyIndex: index
    };
  }
}
