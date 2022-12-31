import 'package:mongo_dart/mongo_dart.dart';

import 'delete_many_options_v1.dart';
import 'delete_many_statement_v1.dart';

class DeleteManyOperationV1 extends DeleteManyOperation {
  DeleteManyOperationV1(
      MongoCollection collection, DeleteManyStatementV1 deleteManyStatement,
      {DeleteManyOptionsV1? deleteManyOptions, super.rawOptions})
      : super.protected(collection, deleteManyStatement,
            deleteManyOptions: deleteManyOptions);
}
