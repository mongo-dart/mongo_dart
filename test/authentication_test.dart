import 'package:test/test.dart';
import 'package:mongo_dart/mongo_dart.dart';

final String mongoDbUri =
    'mongodb://test:test@ds031477.mongolab.com:31477/dart';

main() {
  test("Should be able to connect and authenticate", () async {
    Db db = Db(mongoDbUri, 'test scram sha1');

    await db.open();
    await db.collection('test').find().toList();
    await db.close();
  });

  test(
      "Should be able to connect and authenticate with auth mechanism specified",
      () async {
    Db db = Db('$mongoDbUri?authMechanism=${ScramSha1Authenticator.name}');

    await db.open();
    await db.collection('test').find().toList();
    await db.close();
  });

  test("Can't connect with mongodb-cr on a db without that scheme", () async {
    Db db = Db('$mongoDbUri/?authMechanism=${MongoDbCRAuthenticator.name}');

    var expectedError = {
      'ok': 0.0,
      'errmsg': 'auth failed',
      'code': 18,
      'codeName': 'AuthenticationFailed',
    };

    var err;

    try {
      await db.open();
    } catch (e) {
      err = e;
    }

    bool result = ((err['ok'] == expectedError['ok']) &&
        (err['errmsg'] == expectedError['errmsg']) &&
        (err['code'] == expectedError['code']) &&
        (err['codeName'] == expectedError['codeName']));

    expect(result, true);
  });

  test("Throw exception when auth mechanism isn't supported", () async {
    final String authMechanism = 'Anything';
    Db db = Db('$mongoDbUri?authMechanism=$authMechanism');

    var sut = () async => await db.open();

    expect(
        sut(),
        throwsA(predicate((MongoDartError e) =>
            e.message ==
            'Provided authentication scheme is not supported : $authMechanism')));
  });

  group('RandomStringGenerator', () {
    test("Shouldn't produce twice the same string", () {
      var generator = CryptoStrengthStringGenerator();

      var results = {};

      for (int i = 0; i < 100000; ++i) {
        var generatedString = generator.generate(20);
        if (results.containsKey(generatedString)) {
          fail("Shouldn't have generated 2 identical strings");
        } else {
          results[generatedString] = 1;
        }
      }
    });
  });
}
