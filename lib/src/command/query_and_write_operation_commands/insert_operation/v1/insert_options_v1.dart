import '../base/insert_options.dart';

class InsertOptionsV1 extends InsertOptions {
  InsertOptionsV1(
      {super.writeConcern,
      super.ordered = true,
      super.bypassDocumentValidation = false})
      : super.protected();
}
