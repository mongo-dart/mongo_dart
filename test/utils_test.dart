import 'package:mongo_dart/src/database/utils/check_same_domain.dart'
    show checkSameDomain;
import 'package:mongo_dart/src/database/utils/split_hosts.dart';
import 'package:test/test.dart' show expect, group, isFalse, isTrue, test;

import 'utils/throw_utils.dart' show throwsMongoDartError;

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
}
