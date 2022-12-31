import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/utils/union_type.dart';

class UpdateSpecs extends MultiUnionType<UpdateDocument, MongoDocument,
    List<UpdateDocument>, ModifierBuilder, AggregationPipelineBuilder> {
  UpdateSpecs(super.value) {
    if (isNull) {
      throw MongoDartError('The update Spec cannpt be null');
    }
  }

  List<MongoDocument> get documents {
    switch (value.runtimeType) {
      case UpdateDocument:
        return <UpdateDocument>[value];
      case List<UpdateDocument>:
        return value;
      case MongoDocument:
        return <MongoDocument>[value];
      case ModifierBuilder:
        return <UpdateDocument>[
          (value as ModifierBuilder).map as UpdateDocument
        ];
      case AggregationPipelineBuilder:
        return (value as AggregationPipelineBuilder).build()
            as List<UpdateDocument>;
      default:
        throw MongoDartError(
            'Unexpected value type ${value.runtimeType} in UpdateSpecs');
    }
  }
}
