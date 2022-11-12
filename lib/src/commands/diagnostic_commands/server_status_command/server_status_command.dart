import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/commands/base/command_operation.dart';
import '../../../core/network/abstract/connection_base.dart';
import '../../../database/db.dart';
import '../../../topology/server.dart';
import 'server_status_result.dart';

var _command = <String, Object>{keyServerStatus: 1};

class ServerStatusCommand extends CommandOperation {
  ServerStatusCommand(Db db,
      {ServerStatusOptions? serverStatusOptions,
      Map<String, Object>? rawOptions})
      : super(db,
            <String, Object>{...?serverStatusOptions?.options, ...?rawOptions},
            command: _command);

  Future<ServerStatusResult> executeDocument(Server server,
      {ConnectionBase? connection}) async {
    var result = await super.execute(server, connection: connection);
    return ServerStatusResult(result);
  }

  /// Update basic server info + FeatureCompatibilityVersion
  Future<void> updateServerStatus(Server server,
      {ConnectionBase? connection}) async {
    var result = await super.execute(server, connection: connection);
    // On error the ServerStatus class is not initialized
    // check the `isInitialized` flag.
    //
    // Possible errors are: older version or authorization (requires
    // `clusterMonitor` role if authorization is active)
    server.serverStatus.processServerStatus(result);
  }
}
