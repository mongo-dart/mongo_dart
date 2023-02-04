import 'package:mongo_dart/mongo_dart.dart';

import 'insert_one_options_v1.dart';

class InsertOneOperationV1 extends InsertOneOperation {
  InsertOneOperationV1(super.collection, super.document,
      {super.session, InsertOneOptionsV1? insertOneOptions, super.rawOptions})
      : super.protected(insertOneOptions: insertOneOptions);
}
