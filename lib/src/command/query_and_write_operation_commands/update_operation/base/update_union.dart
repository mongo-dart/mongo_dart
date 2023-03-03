import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/update_operation/base/update_spec.dart';
import 'package:mongo_dart/src/utils/union_type.dart';

class UpdateUnion extends MultiUnionType<UpdateDocument, MongoDocument,
    List<UpdateDocument>, ModifierBuilder, AggregationPipelineBuilder> {
  UpdateUnion(super.value) {
    if (isNull) {
      throw MongoDartError('The update Union cannpt be null');
    }
  }

  UpdateSpec get specs {
    switch (value.runtimeType) {
      case UpdateDocument:
        return UpdateSpec(valueOne);
      case MongoDocument:
        return UpdateSpec(valueTwo);
      case const (List<UpdateDocument>):
        return UpdateSpec(valueThree);
      case ModifierBuilder:
        return UpdateSpec(valueFour!.map);
      case AggregationPipelineBuilder:
        return UpdateSpec(valueFive!.build());
      default:
        throw MongoDartError(
            'Unexpected value type ${value.runtimeType} in UpdateSpecs');
    }
  }
}
