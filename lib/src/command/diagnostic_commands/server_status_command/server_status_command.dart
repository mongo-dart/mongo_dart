import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/command/base/command_operation.dart';
import '../../../database/base/mongo_database.dart';
import '../../../topology/server.dart';
import 'server_status_result.dart';

var _command = <String, dynamic>{keyServerStatus: 1};

class ServerStatusCommand extends CommandOperation {
  ServerStatusCommand(MongoDatabase db,
      {super.session,
      ServerStatusOptions? serverStatusOptions,
      Map<String, Object>? rawOptions})
      : super(
          db,
          _command,
          <String, dynamic>{...?serverStatusOptions?.options, ...?rawOptions},
        );

  Future<ServerStatusResult> executeDocument(Server server) async {
    var result = await super.process();
    return ServerStatusResult(result);
  }

  /// Update basic server info + FeatureCompatibilityVersion
  Future<void> updateServerStatus(Server server) async {
    var result = await super.process();
    // On error the ServerStatus class is not initialized
    // check the `isInitialized` flag.
    //
    // Possible errors are: older version or authorization (requires
    // `clusterMonitor` role if authorization is active)
    server.serverStatus.processServerStatus(result);
  }
}
