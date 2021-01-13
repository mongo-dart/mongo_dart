import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// Selection of status values not expected to change during the same connection
class ServerStatus {
  bool isInitialized = false;

  String host;
  String version;

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
      isInitialized = false;
      return;
    }
    isInitialized = true;
    host = serverStatus[keyHost];
    version = serverStatus[keyVersion];
    process = serverStatus[keyProcess];
    pid = serverStatus[keyPid];
    if (serverStatus[keyRepl] != null) {
      replicaHosts = <String>[
        for (var host in (serverStatus[keyRepl] as Map)[keyHosts]) host
      ];
    }
    // It seems that this key is missing on mongos
    Map storageEngineMap = serverStatus[keyStorageEngine];
    storageEngineName = '';
    isPersistent = true;
    if (storageEngineMap != null) {
      storageEngineName = storageEngineMap[keyName] ?? '';
      isPersistent = storageEngineMap[keyPersistent] ?? true;
      if (storageEngineName == keyWiredTiger) {
        // Atlas service does not return the "wiredTiger" element
        if (!serverStatus.containsKey(keyWiredTiger) ||
            serverStatus[keyWiredTiger][keyLog][keyMaximumLogFileSize] > 0) {
          isJournaled = true;
        }
      }
    }
  }
}
