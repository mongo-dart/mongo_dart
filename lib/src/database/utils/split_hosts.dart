import 'package:mongo_dart/mongo_dart.dart';

List<String> splitHosts(String uriString) {
  String prefix, suffix;
  var startHostsIndex, endServersIndex;
  if (uriString.startsWith('mongodb://')) {
    startHostsIndex = 'mongodb://'.length;
  } else {
    throw MongoDartError('Unexpected scheme in url "$uriString". '
        'The url is expected to start with "mongodb://"');
  }
  endServersIndex = uriString.indexOf('/', startHostsIndex);
  if (endServersIndex == -1) {
    endServersIndex = uriString.length;
    suffix = '';
  } else {
    suffix = uriString.substring(endServersIndex).trim();
  }
  var hostsString = uriString.substring(startHostsIndex, endServersIndex);
  var credentialsIndex = hostsString.indexOf('@');
  if (credentialsIndex != -1) {
    startHostsIndex += credentialsIndex + 1;
    hostsString = uriString.substring(startHostsIndex, endServersIndex);
  }
  prefix = uriString.substring(0, startHostsIndex).trim();
  var parts = hostsString.split(',');
  return [for (var server in parts) '$prefix${server.trim()}$suffix'];
}
