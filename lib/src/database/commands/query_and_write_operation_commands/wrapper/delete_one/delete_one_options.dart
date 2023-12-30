import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/delete_operation/delete_options.dart';

class DeleteOneOptions extends DeleteOptions {
  DeleteOneOptions({super.writeConcern, super.comment});
}
