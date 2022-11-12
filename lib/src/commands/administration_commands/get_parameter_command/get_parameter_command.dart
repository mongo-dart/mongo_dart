import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/commands/base/db_admin_command_operation.dart';
import '../../../database/db.dart';
import 'get_parameter_options.dart';

class GetParameterCommand extends DbAdminCommandOperation {
  GetParameterCommand(Db db, String parameterName,
      {GetParameterOptions? getParameterOptions,
      Map<String, Object>? rawOptions})
      : super(db, <String, Object>{
          keyGetParameter: 1,
          parameterName: 1
        }, options: <String, Object>{
          ...?getParameterOptions?.options,
          ...?rawOptions
        });
}
