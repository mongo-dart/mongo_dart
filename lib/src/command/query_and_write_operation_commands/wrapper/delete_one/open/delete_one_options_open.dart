import '../base/delete_one_options.dart';

class DeleteOneOptionsOpen extends DeleteOneOptions {
  DeleteOneOptionsOpen({super.writeConcern, super.comment}) : super.protected();
}
