import 'package:test/test.dart';
import 'package:mongo_dart/mongo_dart.dart';

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
const tlsQueryParmConnectionString = 'mongodb://cluster0-shard-00-01-smeth'
    '.gcp.mongodb.net:27017/test?tls=true&authSource=admin';

void main() {
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

  test('Ssl wit no secure info => Error', () async {
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
}
