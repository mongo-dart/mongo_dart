
import 'package:vy_string_utils/vy_string_utils.dart';

import '../../../src_old/database/commands/operation.dart';
import '../../utils/map_keys.dart';

class ServerCapabilities {
  int minWireVersion = 0;
  int maxWireVersion = 0;
  bool aggregationCursor = false;
  bool writeCommands = false;
  bool authCommands = false;
  bool listCollections = false;
  bool listIndexes = false;
  int maxNumberOfDocsInBatch = 1000;
  bool supportsOpMsg = false;
  String? replicaSetName;
  List<String>? replicaSetHosts;
  bool get isReplicaSet => replicaSetName != null;
  int get replicaSetHostsNum => replicaSetHosts?.length ?? 0;
  bool get isSingleServerReplicaSet => isReplicaSet && replicaSetHostsNum == 1;
  bool isShardedCluster = false;
  bool isStandalone = false;
  String? fcv;

  void getParamsFromIstMaster(Map<String, dynamic> isMaster) {
    if (isMaster.containsKey('maxWireVersion')) {
      maxWireVersion = isMaster['maxWireVersion'] as int;
    }
    if (maxWireVersion >= 1) {
      aggregationCursor = true;
      authCommands = true;
    }
    if (maxWireVersion >= 2) {
      writeCommands = true;
    }
    if (maxWireVersion >= 3) {
      listCollections = true;
      listIndexes = true;
    }
    if (maxWireVersion >= 6) {
      supportsOpMsg = true;
    }
    if (isMaster.containsKey(keyMsg)) {
      isShardedCluster = true;
    } else if (isMaster.containsKey(keySetName)) {
      replicaSetName = isMaster[keySetName];
      replicaSetHosts = <String>[...isMaster[keyHosts]];
    } else {
      isStandalone = true;
    }
    if (maxWireVersion >= 13) {
      fcv = '5.0';
    } else if (isMaster.containsKey(keyTopologyVersion)) {
      fcv = '4.4';
    } else if (isMaster.containsKey(keyConnectionId)) {
      fcv = '4.2';
    } else if (maxWireVersion > 6) {
      // approximated
      fcv = '4.0';
    } else {
      fcv = '3.6';
    }
  }

  void getParamsFromHello(HelloResult result) {
    minWireVersion = result.minWireVersion;

    maxWireVersion = result.maxWireVersion;

    if (maxWireVersion >= 1) {
      aggregationCursor = true;
      authCommands = true;
    }
    if (maxWireVersion >= 2) {
      writeCommands = true;
    }
    if (maxWireVersion >= 3) {
      listCollections = true;
      listIndexes = true;
    }
    if (maxWireVersion >= 6) {
      supportsOpMsg = true;
    }
    if (filled(result.msg)) {
      isShardedCluster = true;
    } else if (filled(result.setName)) {
      replicaSetName = result.setName;
      replicaSetHosts = <String>[...?result.hosts];
    } else {
      isStandalone = true;
    }

    if (maxWireVersion >= 17) {
      fcv = '6.0';
    } else if (maxWireVersion >= 13) {
      fcv = '5.0';
    } else if (maxWireVersion >= 9) {
      fcv = '4.4';
    } else if (maxWireVersion >= 8) {
      fcv = '4.2';
    } else if (maxWireVersion >= 7) {
      fcv = '4.0';
    } else {
      fcv = '3.6';
    }
  }
}
