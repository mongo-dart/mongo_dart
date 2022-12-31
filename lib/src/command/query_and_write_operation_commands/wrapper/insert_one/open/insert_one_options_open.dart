import '../base/insert_one_options.dart';

class InsertOneOptionsOpen extends InsertOneOptions {
  InsertOneOptionsOpen({super.writeConcern, super.bypassDocumentValidation})
      : super.protected();
}
