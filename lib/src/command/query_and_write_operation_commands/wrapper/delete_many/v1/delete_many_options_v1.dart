import '../base/delete_many_options.dart';

class DeleteManyOptionsV1 extends DeleteManyOptions {
  DeleteManyOptionsV1({super.writeConcern, super.ordered, super.comment})
      : super.protected();
}
