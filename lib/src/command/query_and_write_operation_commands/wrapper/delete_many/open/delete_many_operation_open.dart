import 'package:mongo_dart/mongo_dart.dart';

import 'delete_many_options_open.dart';
import 'delete_many_statement_open.dart';

base class DeleteManyOperationOpen extends DeleteManyOperation {
  DeleteManyOperationOpen(
      MongoCollection collection, DeleteManyStatementOpen deleteManyStatement,
      {super.session,
      DeleteManyOptionsOpen? deleteManyOptions,
      super.rawOptions})
      : super.protected(collection, deleteManyStatement,
            deleteManyOptions: deleteManyOptions);
}
