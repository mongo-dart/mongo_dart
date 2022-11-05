import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src_old/database/commands/base/command_operation.dart';
import '../../../../../src/core/network/deprecated/connection_multi_request.dart';
import 'server_status_result.dart';

var _command = <String, Object>{keyServerStatus: 1};

class ServerStatusCommand extends CommandOperation {
  ServerStatusCommand(Db db,
      {ServerStatusOptions? serverStatusOptions,
      Map<String, Object>? rawOptions})
      : super(db,
            <String, Object>{...?serverStatusOptions?.options, ...?rawOptions},
            command: _command);

  Future<ServerStatusResult> executeDocument() async {
    var result = await super.execute();
    return ServerStatusResult(result);
  }

  /// Update basic server info + FeatureCompatibilityVersion
  Future<void> updateServerStatus(
      ConnectionMultiRequest masterConnection) async {
    if (!masterConnection.serverCapabilities.supportsOpMsg) {
      return;
    }
    var result = await super.execute();
    // On error the ServerStatus class is not initialized
    // check the `isInitialized` flag.
    //
    // Possible errors are: older version or authorization (requires
    // `clusterMonitor` role if authorization is active)
    masterConnection.serverStatus.processServerStatus(result);
  }
}
