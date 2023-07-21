import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/update_operation/base/update_spec.dart';
import 'package:mongo_dart/src/utils/union_type.dart';

class UpdateUnion extends MultiUnionType<UpdateDocument, MongoDocument,
    List<UpdateDocument>, ModifierBuilder, AggregationPipelineBuilder> {
  UpdateUnion(value) : super(transformValue(value)) {
    if (isNull) {
      print(value.runtimeType);
      throw MongoDartError('The update Union cannpt be null');
    }
  }

  static dynamic transformValue(value) {
    if (value is List) {
      if (value is List<UpdateDocument>) {
        return value;
      }
      List<UpdateDocument> lud = <UpdateDocument>[
        for (var element in value) element as UpdateDocument
      ];
      return lud;
    }
    return value;
  }

  UpdateSpec get specs {
    if (value is UpdateDocument) {
      return UpdateSpec(valueOne);
    } else if (value is MongoDocument) {
      return UpdateSpec(valueTwo);
    } else if (value is List<UpdateDocument>) {
      return UpdateSpec(valueThree);
    } else if (value is ModifierBuilder) {
      return UpdateSpec(valueFour!.map);
    } else if (value is AggregationPipelineBuilder) {
      return UpdateSpec(valueFive!.build());
    }

    throw MongoDartError(
        'Unexpected value type ${value.runtimeType} in UpdateSpecs');
  }
}
