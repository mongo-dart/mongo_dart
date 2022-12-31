import '../base/insert_many_options.dart';

class InsertManyOptionsOpen extends InsertManyOptions {
  InsertManyOptionsOpen(
      {super.writeConcern, super.ordered, super.bypassDocumentValidation})
      : super.protected();
}
