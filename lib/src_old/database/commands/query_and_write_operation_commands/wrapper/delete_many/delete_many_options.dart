import 'package:mongo_dart/mongo_dart_old.dart' show WriteConcern;
import 'package:mongo_dart/src_old/database/commands/query_and_write_operation_commands/delete_operation/delete_options.dart';

class DeleteManyOptions extends DeleteOptions {
  DeleteManyOptions({WriteConcern? writeConcern, String? comment})
      : super(writeConcern: writeConcern, comment: comment);
}
