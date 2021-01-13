import 'package:basic_utils/basic_utils.dart' show DnsUtils, RRecordType;
import 'package:mongo_dart/src/database/utils/dns_lookup.dart';
import 'package:test/test.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'utils/throw_utils.dart' show throwsMongoDartError;

const sslDbConnectionString =
    'mongodb://cluster0-shard-00-00-smeth.gcp.mongodb.net:27017/'
    'test?authSource=admin,'
    'mongodb://cluster0-shard-00-01-smeth.gcp.mongodb.net:27017/'
    'test?authSource=admin,'
    'mongodb://cluster0-shard-00-02-smeth.gcp.mongodb.net:27017/'
    'test?authSource=admin';
const sslDbUsername = 'mongo_dart_tester';
const sslDbPassword = 'O8kipHnIyenpc9fV';
const sslQueryParmConnectionString =
    'mongodb://cluster0-shard-00-00-smeth.gcp.mongodb.net:27017,'
    'cluster0-shard-00-01-smeth.gcp.mongodb.net:27017,'
    'cluster0-shard-00-02-smeth.gcp.mongodb.net:27017/'
    'test?authSource=admin&ssl=true';
// Todo manage also the case in which the server is not the primary
const tlsQueryParmConnectionString = 'mongodb://cluster0-shard-00-01-smeth'
    '.gcp.mongodb.net:27017/test?tls=true&authSource=admin';

void main() {
  group('Dns lookup', () {
    test('Testing connection TXT', () async {
      var records =
          await DnsUtils.lookupRecord('rs.joedrumgoole.com', RRecordType.TXT);
      expect(records.first.data, '"authSource=admin&replicaSet=srvdemo"');
    });
    test('Testing connection SRV', () async {
      var records = await DnsUtils.lookupRecord(
          '_mongodb._tcp.' 'rs.joedrumgoole.com', RRecordType.SRV);

      expect(records.first.data, '0 0 27022 rs1.joedrumgoole.com.');
      expect(records[1].data, '0 0 27022 rs2.joedrumgoole.com.');
      expect(records.last.data, '0 0 27022 rs3.joedrumgoole.com.');
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
      var db = await Db.create('mongodb+srv://user:password@'
          'rs.joedrumgoole.com/test?retryWrites=true&w=majority');
      var urilist = db.uriList;
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
    test('Test Atlas connection', () async {
      var db = await Db.create('mongodb+srv:<insert the correct url>');
      await db.open();
      var coll = db.collection('test-insert');
      var result =
          await coll.insertOne({'solved': true, 'autoinit': 'delayed'});
      // Todo update test
      // print(result['ops'].first);
      /* Todo update
      var findResult = await coll.find(where.id(result['insertedId'])).toList();
      print(findResult);
      expect(result['ops'].first['solved'], findResult.first['solved']);
      expect(result['ops'].first['autoinit'], findResult.first['autoinit']); */
      await db.close();
    }, skip: 'Set the correct url before running this test');
  });

  group('Real connection', () {
    test('Connect and authenticate to a database over SSL', () async {
      var db = Db.pool(sslDbConnectionString.split(','));

      await db.open(secure: true);
      await db.authenticate(sslDbUsername, sslDbPassword);
      await db.collection('test').find().toList();
      await db.close();
    });

    test('Ssl as query parm', () async {
      var db = Db(sslQueryParmConnectionString);

      await db.open();
      await db.authenticate(sslDbUsername, sslDbPassword);
      await db.collection('test').find().toList();
      await db.close();
    });

    test('Ssl with no secure info => Error', () async {
      var db = Db.pool(sslDbConnectionString.split(','));
      expect(() => db.open(), throwsA((ConnectionException e) => true));
    });

    test('Tls as query parm', () async {
      var db = Db(tlsQueryParmConnectionString);

      await db.open();
      await db.authenticate(sslDbUsername, sslDbPassword);
      await db.collection('test').find().toList();
      await db.close();
    });
    test('Tls as query parm plus secure parameter', () async {
      var db = Db(tlsQueryParmConnectionString);

      await db.open(secure: true);
      await db.authenticate(sslDbUsername, sslDbPassword);
      await db.collection('test').find().toList();
      await db.close();
    });
  }, skip: 'Requires manual connection string adjustment before run');
}
