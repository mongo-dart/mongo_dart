import 'package:mongo_dart/src/command/parameters/write_concern.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/delete_operation/delete_options.dart';

class DeleteManyOptions extends DeleteOptions {
  DeleteManyOptions({WriteConcern? writeConcern, String? comment})
      : super(writeConcern: writeConcern, comment: comment);
}
