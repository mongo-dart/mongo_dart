import '../../../../../mongo_dart.dart';
import 'find_options_v1.dart';

base class FindOperationV1 extends FindOperation {
  FindOperationV1(super.collection, super.filter,
      {super.sort,
      super.projection,
      super.hint,
      super.skip,
      super.limit,
      super.session,
      FindOptionsV1? findOptions,
      super.rawOptions})
      : super.protected(findOptions: findOptions);
}
