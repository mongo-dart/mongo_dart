import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/db_admin_command_operation.dart';
import 'get_all_parameters_options.dart';

base class GetAllParametersCommand extends DbAdminCommandOperation {
  GetAllParametersCommand(MongoClient client,
      {super.session,
      GetAllParametersOptions? getAllParametersOptions,
      Map<String, Object>? rawOptions})
      : super(client, <String, dynamic>{
          keyGetParameter: '*'
        }, options: <String, dynamic>{
          ...?getAllParametersOptions?.options,
          ...?rawOptions
        });
}
