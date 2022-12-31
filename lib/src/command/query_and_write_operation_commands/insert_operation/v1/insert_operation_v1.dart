import '../base/insert_operation.dart';
import 'insert_options_v1.dart';

class InsertOperationV1 extends InsertOperation {
  InsertOperationV1(super.collection, super.documents,
      {InsertOptionsV1? insertOptions, super.rawOptions})
      : super.protected(insertOptions: insertOptions);
}
