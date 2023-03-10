import 'package:mongo_dart/mongo_dart.dart';

import '../base/find_one_and_update_operation.dart';
import 'find_one_and_update_options_v1.dart';

base class FindOneAndUpdateOperationV1 extends FindOneAndUpdateOperation {
  FindOneAndUpdateOperationV1(MongoCollection collection,
      {super.query,
      super.update,
      super.fields,
      super.sort,
      super.upsert,
      super.returnNew,
      super.arrayFilters,
      super.session,
      super.hint,
      FindOneAndUpdateOptionsV1? findOneAndUpdateOptions,
      super.rawOptions})
      : super.protected(collection,
            findOneAndUpdateOptions: findOneAndUpdateOptions);
}
