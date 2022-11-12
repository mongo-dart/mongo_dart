import 'package:basic_utils/basic_utils.dart';
import 'package:mongo_dart/src/utils/check_same_domain.dart'
    show checkSameDomain;
import 'package:mongo_dart/src/utils/decode_dns_seed_list.dart';
import 'package:mongo_dart/src/utils/split_hosts.dart';
import 'package:test/test.dart' show expect, group, isFalse, isTrue, test;

import 'utils/matcher/mongo_dart_error_matcher.dart';

void main() {
  group('Check Same Domain', () {
    test('Same Domain', () async {
      expect(
          checkSameDomain(
              Uri.parse(
                  'mongodb://cluster0-shard-00-00-smeth.gcp.mongodb.net:27017'),
              Uri.parse(
                  'mongodb://cluster0-shard-00-02-smeth.gcp.mongodb.net:27017/'
                  'test?authSource=admin&ssl=true')),
          isTrue);
      expect(
          checkSameDomain(
              Uri.parse(
                  'mongodb://cluster0-shard-00-00-smeth.gcp.mongodb.net:27017'),
              Uri.parse('http://mongodb.net')),
          isTrue);
    });
    test('Different Domain', () async {
      expect(
          checkSameDomain(
              Uri.parse(
                  'mongodb://cluster0-shard-00-00-smeth.gcp.mongodb.net:27017'),
              Uri.parse(
                  'mongodb://cluster0-shard-00-02-smeth.gcp.mongodb.org:27017/'
                  'test?authSource=admin&ssl=true')),
          isFalse);
      expect(
          checkSameDomain(
              Uri.parse(
                  'mongodb://cluster0-shard-00-00-smeth.gcp.mongodb.net:27017'),
              Uri.parse('http://mongo.net')),
          isFalse);
    });
    test('Error', () async {
      expect(
          () => checkSameDomain(
              Uri.parse('mongodb://mongodb:27017'),
              Uri.parse(
                  'mongodb://cluster0-shard-00-02-smeth.gcp.mongodb.org:27017/'
                  'test?authSource=admin&ssl=true')),
          throwsMongoDartError);
      expect(
          () => checkSameDomain(
              Uri.parse(
                  'mongodb://cluster0-shard-00-00-smeth.gcp.mongodb.net:27017'),
              Uri.parse('http://mongo')),
          throwsMongoDartError);
      expect(
          () => checkSameDomain(
              Uri.parse(
                  'mongodb://cluster0-shard-00-00-smeth.gcp.mongodb.net:27017'),
              Uri.parse('mongodb.net')),
          throwsMongoDartError);
    });
  });

  group('Split Hosts', () {
    test('three hosts', () async {
      var hosts = splitHosts(
          'mongodb:// cluster0-shard-00-00-smeth.gcp.mongodb.net:27017,'
          'cluster0-shard-00-01-smeth.gcp.mongodb.net:27017, '
          'cluster0-shard-00-02-smeth.gcp.mongodb.net:27017/'
          'test?authSource=admin&ssl=true                 ');
      expect(
          hosts.first,
          'mongodb://cluster0-shard-00-00-smeth.gcp.mongodb.net:27017/'
          'test?authSource=admin&ssl=true');
      expect(
          hosts[1],
          'mongodb://cluster0-shard-00-01-smeth.gcp.mongodb.net:27017/'
          'test?authSource=admin&ssl=true');
      expect(
          hosts.last,
          'mongodb://cluster0-shard-00-02-smeth.gcp.mongodb.net:27017/'
          'test?authSource=admin&ssl=true');

      hosts = splitHosts(
          'mongodb:// cluster0-shard-00-00-smeth.gcp.mongodb.net:27017,'
          'cluster0-shard-00-01-smeth.gcp.mongodb.net:27017, '
          'cluster0-shard-00-02-smeth.gcp.mongodb.net:27017');
      expect(hosts.first,
          'mongodb://cluster0-shard-00-00-smeth.gcp.mongodb.net:27017');
      expect(hosts[1],
          'mongodb://cluster0-shard-00-01-smeth.gcp.mongodb.net:27017');
      expect(hosts.last,
          'mongodb://cluster0-shard-00-02-smeth.gcp.mongodb.net:27017');

      hosts = splitHosts(
          'mongodb:// cluster0-shard-00-00-smeth.gcp.mongodb.net:27017,'
          'cluster0-shard-00-01-smeth.gcp.mongodb.net/'
          'test?authSource=admin&ssl=true');
      expect(
          hosts.first,
          'mongodb://cluster0-shard-00-00-smeth.gcp.mongodb.net:27017/'
          'test?authSource=admin&ssl=true');
      expect(
          hosts.last,
          'mongodb://cluster0-shard-00-01-smeth.gcp.mongodb.net/'
          'test?authSource=admin&ssl=true');
    });

    test('Error', () async {
      expect(
          () => splitHosts(
              ' mongodb:// cluster0-shard-00-00-smeth.gcp.mongodb.net:27017,'
              'cluster0-shard-00-01-smeth.gcp.mongodb.net:27017, '
              'cluster0-shard-00-02-smeth.gcp.mongodb.net:27017/'
              'test?authSource=admin&ssl=true'),
          throwsMongoDartError);
      expect(
          () => splitHosts('cluster0-shard-00-00-smeth.gcp.mongodb.net:27017,'
              'cluster0-shard-00-01-smeth.gcp.mongodb.net:27017, '
              'cluster0-shard-00-02-smeth.gcp.mongodb.net:27017/'
              'test?authSource=admin&ssl=true'),
          throwsMongoDartError);
    });
  });

  group('Decode Dns Seed List', () {
    test('Testing connection TXT', () async {
      var records =
          await DnsUtils.lookupRecord('rs.joedrumgoole.com', RRecordType.TXT);
      expect(records?.first.data, 'authSource=admin&replicaSet=srvdemo');
    });
    test('Testing connection SRV', () async {
      var records = await DnsUtils.lookupRecord(
          '_mongodb._tcp.' 'rs.joedrumgoole.com', RRecordType.SRV);

      expect(records?.first.data, '0 0 27022 rs1.joedrumgoole.com.');
      expect(records?[1].data, '0 0 27022 rs2.joedrumgoole.com.');
      expect(records?.last.data, '0 0 27022 rs3.joedrumgoole.com.');
    });

    test('Decode Dns Seedlist', () async {
      var result =
          await decodeDnsSeedlist(Uri.parse('mongodb+srv://user:password@'
              'rs.joedrumgoole.com/test?retryWrites=true&w=majority'));

      expect(
          result.first,
          'mongodb://user:password@rs1.joedrumgoole.com:27022/'
          'test?authSource=admin&replicaSet=srvdemo&'
          'retryWrites=true&w=majority&ssl=true');
      expect(
          result[1],
          'mongodb://user:password@rs2.joedrumgoole.com:27022/'
          'test?authSource=admin&replicaSet=srvdemo&'
          'retryWrites=true&w=majority&ssl=true');
      expect(
          result.last,
          'mongodb://user:password@rs3.joedrumgoole.com:27022/'
          'test?authSource=admin&replicaSet=srvdemo&'
          'retryWrites=true&w=majority&ssl=true');
    });
    test('Decode Dns Seedlist - sync', () {
      decodeDnsSeedlist(Uri.parse('mongodb+srv://user:password@'
              'rs.joedrumgoole.com/test?retryWrites=true&w=majority'))
          .then((result) {
        expect(
            result.first,
            'mongodb://user:password@rs1.joedrumgoole.com:27022/'
            'test?authSource=admin&replicaSet=srvdemo&'
            'retryWrites=true&w=majority&ssl=true');
        expect(
            result[1],
            'mongodb://user:password@rs2.joedrumgoole.com:27022/'
            'test?authSource=admin&replicaSet=srvdemo&'
            'retryWrites=true&w=majority&ssl=true');
        expect(
            result.last,
            'mongodb://user:password@rs3.joedrumgoole.com:27022/'
            'test?authSource=admin&replicaSet=srvdemo&'
            'retryWrites=true&w=majority&ssl=true');
      });
    });
    test('Decode Dns Seedlist - Wrong host error', () async {
      expect(
          () async => decodeDnsSeedlist(Uri.parse('mongodb+srv://user:password@'
              'rsx.joedrumgoole.com/test?retryWrites=true&w=majority')),
          throwsMongoDartError);
    });
    test('Decode Dns Seedlist - More than one host error', () async {
      expect(
          () async => decodeDnsSeedlist(Uri.parse('mongodb+srv://user:password@'
              'rs.joedrumgoole.com, rs2.joedrumgoole.com/'
              'test?retryWrites=true&w=majority')),
          throwsMongoDartError);
    });
    test('Db creation with seedlist format url', () async {
      var uriList =
          await decodeDnsSeedlist(Uri.parse('mongodb+srv://user:password@'
              'rs.joedrumgoole.com/test?retryWrites=true&w=majority'));
      var urilist = uriList;
      expect(
          urilist.first,
          'mongodb://user:password@rs1.joedrumgoole.com:27022/'
          'test?authSource=admin&replicaSet=srvdemo&'
          'retryWrites=true&w=majority&ssl=true');
      expect(
          urilist[1],
          'mongodb://user:password@rs2.joedrumgoole.com:27022/'
          'test?authSource=admin&replicaSet=srvdemo&'
          'retryWrites=true&w=majority&ssl=true');
      expect(
          urilist.last,
          'mongodb://user:password@rs3.joedrumgoole.com:27022/'
          'test?authSource=admin&replicaSet=srvdemo&'
          'retryWrites=true&w=majority&ssl=true');
    });
  });
}
