import 'base/insert_options.dart';

class InsertOptionsOpen extends InsertOptions {
  InsertOptionsOpen(
      {super.writeConcern,
      super.ordered = true,
      super.bypassDocumentValidation = false})
      : super.protected();
}
