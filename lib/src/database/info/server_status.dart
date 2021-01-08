import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// Selection of status values not expected to change during the same connection
class ServerStatus {
  String host;
  String version;

  /// Feature Compatibility Version
  String fcv;

  /// The current MongoDB process. Possible values are: mongos or mongod.
  String process;
  String storageEngineName;
  bool isJournaled = false;
  bool isPersistent = true;
  int pid;

  /// If the cluster is a replica set, here we have the list of the hosts
  List<String> replicaHosts;

  bool get isReplicaSet => replicaHosts != null;
  bool get isShardedCluster => process == 'mongos';
  bool get isStandalone => !isReplicaSet && !isShardedCluster;
  int get replicaSetHostsNum => replicaHosts?.length ?? 0;
  bool get isSingleServerReplicaSet => isReplicaSet && replicaSetHostsNum == 1;

  void processServerStatus(Map<String, dynamic> serverStatus) {
    if (serverStatus == null ||
        serverStatus.isEmpty ||
        !serverStatus.containsKey(keyOk) ||
        serverStatus[keyOk] != 1.0) {
      return;
    }
    host = serverStatus[keyHost];
    version = serverStatus[keyVersion];
    process = serverStatus[keyProcess];
    pid = serverStatus[keyPid];
    if (serverStatus[keyRepl] != null) {
      replicaHosts = (serverStatus[keyRepl] as Map)[keyHosts];
    }
    storageEngineName = serverStatus[keyStorageEngine][keyName];
    isPersistent = serverStatus[keyStorageEngine][keyPersistent] ?? true;
    if (storageEngineName == keyWiredTiger) {
      // Atlas service does not return the "wiredTiger" element
      if (!serverStatus.containsKey(keyWiredTiger) ||
          serverStatus[keyWiredTiger][keyLog][keyMaximumLogFileSize] > 0) {
        isJournaled = true;
      }
    }
  }
}
