import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/delete_one/open/delete_one_options_open.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/delete_one/open/delete_one_statement_open.dart';

base class DeleteOneOperationOpen extends DeleteOneOperation {
  DeleteOneOperationOpen(
      MongoCollection collection, DeleteOneStatementOpen deleteOneStatement,
      {super.session, DeleteOneOptionsOpen? deleteOneOptions, super.rawOptions})
      : super.protected(collection, deleteOneStatement,
            deleteOneOptions: deleteOneOptions);
}
