import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/commands/administration_commands/create_command/create_options.dart';
import 'package:mongo_dart/src/database/commands/parameters/collation_options.dart';

class CreateCollectionOptions extends CreateOptions {
  CreateCollectionOptions({
    bool? capped,
    int? size,
    bool? autoIndexId,
    int? max,
    Map<String, dynamic>? storageEngine,
    Map<dynamic, dynamic>? validator,
    String? validationLevel,
    String? validationAction,
    Map<String, Object>? indexOptionDefaults,
    CollationOptions? collation,
    WriteConcern? writeConcern,
    String? comment,
  }) : super(
            capped: capped,
            size: size,
            autoIndexId: autoIndexId,
            max: max,
            storageEngine: storageEngine,
            validator: validator,
            validationLevel: validationLevel,
            validationAction: validationAction,
            indexOptionDefaults: indexOptionDefaults,
            collation: collation,
            writeConcern: writeConcern,
            comment: comment);
}
