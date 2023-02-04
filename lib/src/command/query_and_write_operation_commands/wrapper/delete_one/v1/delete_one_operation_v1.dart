import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/delete_one/v1/delete_one_statement_v1.dart';

import 'delete_one_options_v1.dart';

class DeleteOneOperationV1 extends DeleteOneOperation {
  DeleteOneOperationV1(
      MongoCollection collection, DeleteOneStatementV1 deleteOneStatement,
      {super.session, DeleteOneOptionsV1? deleteOneOptions, super.rawOptions})
      : super.protected(collection, deleteOneStatement,
            deleteOneOptions: deleteOneOptions);
}
