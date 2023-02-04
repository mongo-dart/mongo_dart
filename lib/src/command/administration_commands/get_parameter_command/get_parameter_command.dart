import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/db_admin_command_operation.dart';
import 'get_parameter_options.dart';

class GetParameterCommand extends DbAdminCommandOperation {
  GetParameterCommand(MongoClient client, String parameterName,
      {super.session,
      GetParameterOptions? getParameterOptions,
      Map<String, Object>? rawOptions})
      : super(client, <String, dynamic>{
          keyGetParameter: 1,
          parameterName: 1
        }, options: <String, dynamic>{
          ...?getParameterOptions?.options,
          ...?rawOptions
        });
}
