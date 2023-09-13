import 'package:mongo_dart_query/mongo_query.dart';

import 'base/union_type.dart';

class SortUnion extends UnionType<IndexDocument, SortExpression> {
  const SortUnion(super.value);

  IndexDocument get sort {
    if (isNull) {
      return emptyIndexDocument;
    }
    if (valueOne != null) {
      return {...?valueOne};
    }

    return valueTwo!.rawContent;
  }
}
