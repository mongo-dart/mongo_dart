import '../base/insert_many_options.dart';

class InsertManyOptionsV1 extends InsertManyOptions {
  InsertManyOptionsV1(
      {super.writeConcern, super.ordered, super.bypassDocumentValidation})
      : super.protected();
}
