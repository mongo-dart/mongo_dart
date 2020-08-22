import 'package:mongo_dart/mongo_dart.dart';

List<String> splitHosts(String uriString) {
  String prefix, suffix;
  var startServersIndex, endServersIndex;
  if (uriString.startsWith('mongodb://')) {
    startServersIndex = 10;
  } else {
    throw MongoDartError('Unexpected scheme in url $uriString. '
        'The url is expected to start with "mongodb://"');
  }
  endServersIndex = uriString.indexOf('/', startServersIndex);
  var serversString = uriString.substring(startServersIndex, endServersIndex);
  var credentialsIndex = serversString.indexOf('@');
  if (credentialsIndex != -1) {
    startServersIndex += credentialsIndex + 1;
    serversString = uriString.substring(startServersIndex, endServersIndex);
  }
  prefix = uriString.substring(0, startServersIndex);
  suffix = uriString.substring(endServersIndex);
  var parts = serversString.split(',');
  return [for (var server in parts) '$prefix${server.trim()}$suffix'];
}
