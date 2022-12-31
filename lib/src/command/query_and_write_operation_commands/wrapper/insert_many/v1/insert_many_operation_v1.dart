import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/wrapper/insert_many/v1/insert_many_options_v1.dart';

class InsertManyOperationV1 extends InsertManyOperation {
  InsertManyOperationV1(super.collection, super.document,
      {InsertManyOptionsV1? insertManyOptions, super.rawOptions})
      : super.protected(insertManyOptions: insertManyOptions);
}
