import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/update_one/open/update_one_options_open.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/update_one/open/update_one_statement_open.dart';

class UpdateOneOperationOpen extends UpdateOneOperation {
  UpdateOneOperationOpen(
      MongoCollection collection, UpdateOneStatementOpen updateOneStatement,
      {UpdateOneOptionsOpen? updateOneOptions, super.rawOptions})
      : super.protected(collection, updateOneStatement,
            updateOneOptions: updateOneOptions);
}
