import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/replace_one/open/replace_one_options_open.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/replace_one/open/replace_one_statement_open.dart';

base class ReplaceOneOperationOpen extends ReplaceOneOperation {
  ReplaceOneOperationOpen(
      MongoCollection collection, ReplaceOneStatementOpen replaceOneStatement,
      {super.session,
      ReplaceOneOptionsOpen? replaceOneOptions,
      super.rawOptions})
      : super.protected(collection, replaceOneStatement,
            replaceOneOptions: replaceOneOptions);
}
