import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/command/base/db_admin_command_operation.dart';
import '../../../database/mongo_database.dart';
import 'get_parameter_options.dart';

class GetParameterCommand extends DbAdminCommandOperation {
  GetParameterCommand(MongoDatabase db, String parameterName,
      {GetParameterOptions? getParameterOptions,
      Map<String, Object>? rawOptions})
      : super(db, <String, dynamic>{
          keyGetParameter: 1,
          parameterName: 1
        }, options: <String, dynamic>{
          ...?getParameterOptions?.options,
          ...?rawOptions
        });
}
