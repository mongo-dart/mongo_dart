import 'package:mongo_dart_query/mongo_query.dart';

import 'base/union_type.dart';

class ProjectionUnion
    extends UnionType<ProjectionDocument, ProjectionExpression> {
  const ProjectionUnion(super.value);

  ProjectionDocument get projection {
    if (isNull) {
      return emptyProjectionDocument;
    }
    if (valueOne != null) {
      return {...?valueOne};
    }

    return valueTwo!.rawContent;
  }
}
