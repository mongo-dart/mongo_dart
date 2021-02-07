import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/operation/commands/base/db_admin_command_operation.dart';
import 'get_parameter_options.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class GetParameterCommand extends DbAdminCommandOperation {
  GetParameterCommand(Db db, String parameterName,
      {GetParameterOptions getParameterOptions, Map<String, Object> rawOptions})
      : super(db, <String, Object>{
          keyGetParameter: 1,
          parameterName: 1
        }, options: <String, Object>{
          ...?getParameterOptions?.options,
          ...?rawOptions
        });
}
