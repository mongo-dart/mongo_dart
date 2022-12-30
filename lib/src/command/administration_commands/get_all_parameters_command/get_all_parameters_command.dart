import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/command/base/db_admin_command_operation.dart';
import '../../../database/base/mongo_database.dart';
import 'get_all_parameters_options.dart';

class GetAllParametersCommand extends DbAdminCommandOperation {
  GetAllParametersCommand(MongoDatabase db,
      {GetAllParametersOptions? getAllParametersOptions,
      Map<String, Object>? rawOptions})
      : super(db, <String, dynamic>{
          keyGetParameter: '*'
        }, options: <String, dynamic>{
          ...?getAllParametersOptions?.options,
          ...?rawOptions
        });
}
