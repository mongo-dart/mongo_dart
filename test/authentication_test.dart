import 'package:test/test.dart';
import 'package:mongo_dart/mongo_dart.dart';

final String mongoDbUri =
    'mongodb://test:test@ds031477.mongolab.com:31477/dart';

main() {
  test("Should be able to connect and authenticate", () async {
    Db db = new Db(mongoDbUri, 'test scram sha1');

    await db.open();
    await db.collection('test').find().toList();
    await db.close();
  });

  test(
      "Should be able to connect and authenticate with auth mechanism specified",
      () async {
    Db db = new Db('$mongoDbUri?authMechanism=${ScramSha1Authenticator.name}');

    await db.open();
    await db.collection('test').find().toList();
    await db.close();
  });

  test("Can't connect with mongodb-cr on a db without that scheme", () async {
    Db db = new Db('$mongoDbUri/?authMechanism=${MongoDbCRAuthenticator.name}');

    var sut = () async => await db.open();

    expect(
        sut(),
        throwsA(predicate((e) =>
            e.toString() == '{ok: 0.0, errmsg: auth failed, code: 18}')));
  });

  test("Throw exception when auth mechanism isn't supported", () async {
    final String authMechanism = 'Anything';
    Db db = new Db('$mongoDbUri?authMechanism=$authMechanism');

    var sut = () async => await db.open();

    expect(
        sut(),
        throwsA(predicate((MongoDartError e) => e.message ==
            'Provided authentication scheme is not supported : $authMechanism')));
  });
}
