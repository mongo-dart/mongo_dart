import 'package:mongo_dart/mongo_dart.dart';

import 'union_type.dart';

class HintUnion extends UnionType<String, IndexDocument> {
  HintUnion(super.value);
}
