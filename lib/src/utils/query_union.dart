import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';

import 'union_type.dart';

class QueryUnion extends UnionType<QueryFilter, SelectorBuilder> {
  QueryUnion(super.value);

  QueryFilter get query {
    if (isNull) {
      return emptyQueryFilter;
    }
    if (valueOne != null) {
      return {...?valueOne};
    }

    return valueTwo!.map[key$Query] as QueryFilter? ?? emptyQueryFilter;
  }
}
