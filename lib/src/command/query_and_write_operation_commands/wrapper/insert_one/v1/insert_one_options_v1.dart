import '../base/insert_one_options.dart';

class InsertOneOptionsV1 extends InsertOneOptions {
  InsertOneOptionsV1({super.writeConcern, super.bypassDocumentValidation})
      : super.protected();
}
