import 'package:mongo_dart/src/database/operation/commands/query_and_write_operation_commands/delete_operation/delete_request.dart';
import 'package:mongo_dart/src/database/operation/parameters/collation_options.dart';

class DeleteOneRequest extends DeleteRequest {
  DeleteOneRequest(Map<String, Object> filter,
      {CollationOptions collation,
      String hint,
      Map<String, Object> hintDocument})
      : super(filter,
            collation: collation,
            hint: hint,
            hintDocument: hintDocument,
            limit: 1);
}
