import '../base/delete_options.dart';

class DeleteOptionsV1 extends DeleteOptions {
  DeleteOptionsV1({super.writeConcern, super.ordered, super.comment})
      : super.protected();
}
