import 'package:mongo_dart/mongo_dart.dart';

import 'update_many_options_open.dart';
import 'update_many_statement_open.dart';

class UpdateManyOperationOpen extends UpdateManyOperation {
  UpdateManyOperationOpen(
      MongoCollection collection, UpdateManyStatementOpen updateManyStatement,
      {super.ordered,
      super.session,
      UpdateManyOptionsOpen? updateManyOptions,
      super.rawOptions})
      : super.protected(collection, updateManyStatement,
            updateManyOptions: updateManyOptions);
}
