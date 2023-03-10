import 'package:mongo_dart/mongo_dart.dart';

import 'update_many_options_v1.dart';
import 'update_many_statement_v1.dart';

base class UpdateManyOperationV1 extends UpdateManyOperation {
  UpdateManyOperationV1(
      MongoCollection collection, UpdateManyStatementV1 updateManyStatement,
      {super.ordered,
      super.session,
      UpdateManyOptionsV1? updateManyOptions,
      super.rawOptions})
      : super.protected(collection, updateManyStatement,
            updateManyOptions: updateManyOptions);
}
