import 'package:test/test.dart';
import 'package:mongo_dart/mongo_dart.dart';

const sslDbConnectionString =
    'mongodb://cluster0-shard-00-00-smeth.gcp.mongodb.net:27017/test?authSource=admin,mongodb://cluster0-shard-00-01-smeth.gcp.mongodb.net:27017/test?authSource=admin,mongodb://cluster0-shard-00-02-smeth.gcp.mongodb.net:27017/test?authSource=admin';
const sslDbUsername = 'mongo_dart_tester';
const sslDbPassword = 'O8kipHnIyenpc9fV';

void main() {
  test('Connect and authenticate to a database over SSL', () async {
    var db = Db.pool(sslDbConnectionString.split(','));

    await db.open(secure: true);
    await db.authenticate(sslDbUsername, sslDbPassword);
    await db.collection('test').find().toList();
    await db.close();
  });
}
