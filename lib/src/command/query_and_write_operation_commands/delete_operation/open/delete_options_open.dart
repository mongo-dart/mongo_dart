import '../base/delete_options.dart';

class DeleteOptionsOpen extends DeleteOptions {
  DeleteOptionsOpen({super.writeConcern, super.ordered, super.comment})
      : super.protected();
}
