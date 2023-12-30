import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/delete_operation/delete_options.dart';

class DeleteManyOptions extends DeleteOptions {
  DeleteManyOptions({super.writeConcern, super.comment});
}
