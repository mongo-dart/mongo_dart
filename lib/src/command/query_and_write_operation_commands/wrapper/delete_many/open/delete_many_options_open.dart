import '../base/delete_many_options.dart';

class DeleteManyOptionsOpen extends DeleteManyOptions {
  DeleteManyOptionsOpen({super.writeConcern, super.ordered, super.comment})
      : super.protected();
}
