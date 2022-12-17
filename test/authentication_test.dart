import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/mongo_client.dart';
import 'package:sasl_scram/sasl_scram.dart' show CryptoStrengthStringGenerator;
import 'package:test/test.dart';

import 'package:mongo_dart/src/core/auth/scram_sha1_authenticator.dart'
    show ScramSha1Authenticator;
import 'package:mongo_dart/src/core/auth/scram_sha256_authenticator.dart'
    show ScramSha256Authenticator;
//final String mongoDbUri =
//    'mongodb://test:test@ds031477.mlab.com:31477/dart';

const dbName = 'mongodb-auth';
const dbAddress = '127.0.0.1';

const mongoDbUri = 'mongodb://test:test@$dbAddress:27017/$dbName';
const mongoDbUri2 = 'mongodb://unicode:übelkübel@$dbAddress:27017/$dbName';

void main() async {
  Future<bool> testDatabase(String uri) async {
    var client = MongoClient(uri);
    try {
      await client.connect();
      var db = client.db();
      var val = db.server.isAuthenticated;
      await client.close();
      return val;
    } on MongoDartError catch (e) {
      if (e.mongoCode == 18) {
        return false;
      }
      rethrow;
    } on Map catch (e) {
      if (e.containsKey(keyCode)) {
        if (e[keyCode] == 18) {
          return false;
        }
      }
      throw StateError('Unknown error $e');
    } catch (e) {
      throw StateError('Unknown error $e');
    }
  }

  Future<String?> getFcv(String uri) async {
    var client = MongoClient(uri);
    try {
      await client.connect();
      var db = client.db();

      var fcv = db.server.serverCapabilities.fcv;

      await client.close();
      return fcv;
    } on Map catch (e) {
      if (e.containsKey(keyCode)) {
        if (e[keyCode] == 18) {
          return null;
        }
      }
      throw StateError('Unknown error $e');
    } catch (e) {
      throw StateError('Unknown error $e');
    }
  }

  group('Authentication', () {
    var serverRequiresAuth = false;
    var isVer3_6 = false;

    setUpAll(() async {
      serverRequiresAuth = await testDatabase(mongoDbUri);
      if (serverRequiresAuth) {
        var fcv = await getFcv(mongoDbUri);
        isVer3_6 = fcv == '3.6';
      }
    });

    group('General Test', () {
      test('Should be able to connect and authenticate', () async {
        if (serverRequiresAuth) {
          var client = MongoClient(mongoDbUri);
          await client.connect();
          final db = client.db();

          await db.collection('test').find().toList();
          await client.close();
        }
      });

      test('Should be able to connect and authenticate with scram sha1',
          () async {
        if (serverRequiresAuth) {
          var client = MongoClient(
              '$mongoDbUri?authMechanism=${ScramSha1Authenticator.name}');
          await client.connect();
          final db = client.db();

          expect(db.server.isAuthenticated, isTrue);
          await db.collection('test').find().toList();
          await client.close();
        }
      });
      test('Should be able to connect and authenticate with scram sha256',
          () async {
        if (serverRequiresAuth && !isVer3_6) {
          var client = MongoClient(
              '$mongoDbUri?authMechanism=${ScramSha256Authenticator.name}');
          await client.connect();
          var db = client.db();

          expect(db.server.isAuthenticated, isTrue);
          await db.collection('test').find().toList();
          await client.close();
          client = MongoClient(
              '$mongoDbUri2?authMechanism=${ScramSha256Authenticator.name}');
          await client.connect();
          db = client.db();

          expect(db.server.isAuthenticated, isTrue);
          await db.collection('test').find().toList();
          await client.close();
        }
      });

      test("Throw exception when auth mechanism isn't supported", () async {
        final authMechanism = 'Anything';
        var client = MongoClient('$mongoDbUri?authMechanism=$authMechanism');

        dynamic sut() async => await client.connect();

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

          for (var i = 0; i < 100000; ++i) {
            var generatedString = generator.generate(20);
            if (results.containsKey(generatedString)) {
              fail("Shouldn't have generated 2 identical strings");
            } else {
              results[generatedString] = 1;
            }
          }
        });
      });
    });
  });
}
