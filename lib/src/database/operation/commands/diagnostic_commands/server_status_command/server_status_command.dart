import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/operation/base/db_admin_command_operation.dart';
import 'package:mongo_dart/src/database/operation/commands/administration_commands/get_parameter_command/get_parameter_command.dart';
import 'server_status_options.dart';
import 'server_status_result.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

var _command = const <String, Object>{keyServerStatus: 1};

class ServerStatusCommand extends DbAdminCommandOperation {
  ServerStatusCommand(Db db,
      {ServerStatusOptions serverStatusOptions, Map<String, Object> rawOptions})
      : super(db, _command,
            options: serverStatusOptions?.options ?? rawOptions);

  Future<ServerStatusResult> executeDocument() async {
    var result = await super.execute();
    return ServerStatusResult(result);
  }

  /// Update basic server info + FeatureCompatibilityVersion
  Future<void> updateServerStatus(Connection masterConnection) async {
    if (!masterConnection.serverCapabilities.supportsOpMsg) {
      return;
    }
    var result = await super.execute();
    masterConnection.serverStatus.processServerStatus(result);

    // set fcv
    masterConnection.serverStatus.fcv = masterConnection.serverStatus.version
        .split('.')
        .sublist(0, 2)
        .join('.');
    // unfortunately mongos does not return the fcv.
    if (masterConnection.serverStatus.process == 'mongod') {
      var ret = await GetParameterCommand(db, keyFeatureCompatibilityVersion)
          .execute();
      if (ret != null) {
        Map<String, Object> fcvMap = ret[keyFeatureCompatibilityVersion];
        if (fcvMap != null) {
          masterConnection.serverStatus.fcv = fcvMap[keyVersion];
        }
      }
    }
  }
}
