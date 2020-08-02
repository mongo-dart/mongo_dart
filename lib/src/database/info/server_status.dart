import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// Selection of status values not expected to change during the same connection
class ServerStatus {
  String host;
  String version;
  String storageEngineName;
  bool isJournaled = false;
  bool isPersistent = true;

  /// mongod | mongos
  String process;

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
    storageEngineName = serverStatus[keyStorageEngine][keyName];
    isPersistent = serverStatus[keyStorageEngine][keyPersistent] ?? true;
    if (storageEngineName == keyWiredTiger) {
      if (serverStatus[keyWiredTiger][keyLog][keyMaximumLogFileSize] > 0) {
        isJournaled = true;
      }
    }
  }
}
