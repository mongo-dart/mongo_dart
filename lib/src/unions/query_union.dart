import 'package:mongo_dart_query/mongo_query.dart';

import 'base/union_type.dart';

class QueryUnion extends UnionType<QueryFilter, FilterExpression> {
  const QueryUnion(super.value);

  QueryFilter get query {
    if (isNull) {
      return emptyQueryFilter;
    }
    if (valueOne != null) {
      return {...?valueOne};
    }

    return valueTwo!.rawContent;
  }
}
