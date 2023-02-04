import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/replace_one/v1/replace_one_statement_v1.dart';

import 'replace_one_options_v1.dart';

class ReplaceOneOperationV1 extends ReplaceOneOperation {
  ReplaceOneOperationV1(
      MongoCollection collection, ReplaceOneStatementV1 replaceOneStatement,
      {super.session, ReplaceOneOptionsV1? replaceOneOptions, super.rawOptions})
      : super.protected(collection, replaceOneStatement,
            replaceOneOptions: replaceOneOptions);
}
