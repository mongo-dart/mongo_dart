import 'package:basic_utils/basic_utils.dart' show DnsUtils, RRecordType;
import 'package:mongo_dart/mongo_dart.dart' show MongoDartError;

/// This method receive an Uri with "mongodb+srv" schema and returns
/// A List of urls in "mongodb" schema format
Future<List<String>> decodeDnsSeedlist(Uri dnsSeedlistUri) async {
  assert(dnsSeedlistUri.scheme == 'mongodb+srv',
      'The method "decodeDnsSeedlist" requires an Uri with mongodb+srv schema');
  if (dnsSeedlistUri.host.contains(',')) {
    throw MongoDartError('mongodb+srv schema Uri requires only one host, '
        'while more then one have been found in host section '
        '("${dnsSeedlistUri.host}")');
  }
  var records =
      await DnsUtils.lookupRecord(dnsSeedlistUri.host, RRecordType.TXT);
  if (records == null) {
    throw MongoDartError('It is impossible to contact the DNS server'
        ' or the host "${dnsSeedlistUri.host}" is not correct.');
  }
  if (records.isEmpty) {
    throw MongoDartError('DNS data is not correct (missing TXT detail)');
  }
  var additionalParms = records.first.data.replaceAll('"', '');
  records = await DnsUtils.lookupRecord(
      '_mongodb._tcp.${dnsSeedlistUri.host}', RRecordType.SRV);
  if (records == null) {
    throw MongoDartError('Impossible to contact the DNS server');
  }
  if (records.isEmpty) {
    throw MongoDartError('DNS data is not correct (missing SRV detail)');
  }
  var user = dnsSeedlistUri.userInfo;
  var postPrefix = user == null || user.isEmpty ? '' : '$user@';
  var prefix = 'mongodb://$postPrefix';
  var requestedParameters =
      dnsSeedlistUri.queryParameters ?? <String, String>{};
  var dnsServerParameters =
      Uri.parse('mongodb://db.example.com/?$additionalParms').queryParameters ??
          <String, String>{};
  var actualParameters = <String, String>{
    ...dnsServerParameters,
    ...requestedParameters
  };
  var tlsString = actualParameters['tls'] ?? actualParameters['ssl'];
  if (tlsString == null) {
    actualParameters['ssl'] = 'true';
  }
  var suffix = StringBuffer(dnsSeedlistUri.path);
  if (actualParameters.isNotEmpty) {
    var isFirst = true;
    for (var key in actualParameters.keys) {
      if (isFirst) {
        suffix.write('?');
        isFirst = false;
      } else {
        suffix.write('&');
      }
      suffix.write('$key=${actualParameters[key]}');
    }
  }
  var addresses = <String>[];
  for (var record in records) {
    var parts = record.data.split(' ');
    String host;
    if (parts.last.endsWith('.')) {
      host = parts.last.substring(0, parts.last.length - 1);
    } else {
      host = parts.last;
    }
    addresses.add('$host:${parts[parts.length - 2]}');
  }
  return <String>[for (var address in addresses) '$prefix$address$suffix'];
}
