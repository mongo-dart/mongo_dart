import '../base/delete_one_options.dart';

class DeleteOneOptionsV1 extends DeleteOneOptions {
  DeleteOneOptionsV1({super.writeConcern, super.comment}) : super.protected();
}
