import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src_old/database/commands/base/db_admin_command_operation.dart';
import 'get_all_parameters_options.dart';

class GetAllParametersCommand extends DbAdminCommandOperation {
  GetAllParametersCommand(Db db,
      {GetAllParametersOptions? getAllParametersOptions,
      Map<String, Object>? rawOptions})
      : super(db, <String, Object>{
          keyGetParameter: '*'
        }, options: <String, Object>{
          ...?getAllParametersOptions?.options,
          ...?rawOptions
        });
}
