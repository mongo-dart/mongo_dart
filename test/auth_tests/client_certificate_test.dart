// ignore_for_file: unused_local_variable

import 'package:universal_io/io.dart';

import 'package:test/test.dart';
import 'package:mongo_dart/mongo_dart.dart';

// Insert in your hosts file:
// 127.0.0.1 server1
//
// Run server1 with these parameters:
// mongod --port 27017  --dbpath <your-data-path> --oplogSize 128
//  --tlsMode requireTLS --tlsCertificateKeyFile
//  <your-mongo-dart-folder>/test/certificates_for_testing/server1.pem
//  --tlsCAFile
//  <your-mongo-dart-folder>/test/certificates_for_testing/mongo-test-ca-full-chain.crt
//
const dbName = 'mongo-dart-server-client-cert';
const dbServerName = 'server1';

const defaultUri = 'mongodb://127.0.0.1:27036/$dbName';

void main() async {
  bool serverfound = false;
  bool isVer3_2 = false;
  bool isVer3_6 = false;
  bool isNoMoreMongodbCR = false;
  var caCertFile = File('${Directory.current.path}'
      '/test/certificates_for_testing/mongo-test-ca-full-chain.crt');
  var pemFile = File('${Directory.current.path}'
      '/test/certificates_for_testing/client.mongo.pem');
  var wrongPemFile = File('test/certificates_for_testing/client.mongo.crt');

  Future<bool> findServer(String uriString) async {
    var db = Db(uriString);
    Uri uri = Uri.parse(uriString);
    try {
      await db.open(
          secure: true,
          tlsCAFile: caCertFile.path,
          tlsCertificateKeyFile: pemFile.path);
      await db.close();
      return true;
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
      // When the server is not reachable on the required address (port!?)
    } on ConnectionException catch (e) {
      if (e.message.contains(':${uri.port}')) {
        return false;
      }
      throw StateError('Unknown error $e');
    } catch (e) {
      throw StateError('Unknown error $e');
    }
  }

  Future<String?> getFcv(String uri) async {
    var db = Db(uri);
    try {
      await db.open(
          secure: true,
          tlsCAFile: caCertFile.path,
          tlsCertificateKeyFile: pemFile.path);
      var fcv = db.masterConnection.serverCapabilities.fcv;

      await db.close();
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

  serverfound = await findServer(defaultUri);
  if (serverfound) {
    var fcv = await getFcv(defaultUri);
    isVer3_2 = fcv == '3.2';
    isVer3_6 = fcv == '3.6';
    if (fcv != null) {
      isNoMoreMongodbCR = fcv.length != 3 || fcv.compareTo('5.9') == 1;
    }
  }

  group('Client certificate', () {
    if (!serverfound) {
      return;
    }

    test('Should not be able to connect missing key file and CA file',
        () async {
      var db = Db(defaultUri);

      try {
        await db.open(secure: true);
        // after the first run certificates are in the hash table.
        expect(true, isTrue);
      } on ConnectionException {
        expect(true, isTrue);
      } catch (e) {
        expect(true, isFalse);
      } finally {
        await db.close();
      }
    });

    test('Should not be able to connect missing key file', () async {
      var db = Db(defaultUri);

      try {
        await db.open(secure: true, tlsCAFile: caCertFile.path);
        // after the first run certificates are in the hash table.
        expect(true, isTrue);
      } on ConnectionException {
        expect(true, isTrue);
      } catch (e) {
        expect(true, isFalse);
      } finally {
        await db.close();
      }
    });

    // Check to avoid problems with the
    // "certificate already in hash table error"
    test(
        'Should not be able to connect missing key file, CA File given 2 times',
        () async {
      var db = Db(defaultUri);

      try {
        await db.open(secure: true, tlsCAFile: caCertFile.path);
        // after the first run certificates are in the hash table.
        expect(true, isTrue);
      } on ConnectionException {
        expect(true, isTrue);
      } catch (e) {
        expect(true, isFalse);
      } finally {
        await db.close();
      }
    });

    test('Wrong pem file', () async {
      var db = Db(defaultUri);
      try {
        await db.open(
            secure: true,
            tlsCAFile: caCertFile.path,
            tlsCertificateKeyFile: wrongPemFile.path);
        await db.close();
        expect(true, isFalse);
      } on ConnectionException {
        expect(true, isTrue);
      } catch (e) {
        expect(true, isFalse);
      } finally {
        await db.close();
      }
    });
    test('Connect no problems with cert', () async {
      var db = Db(defaultUri);

      await db.open(
          secure: true,
          tlsCAFile: caCertFile.path,
          tlsCertificateKeyFile: pemFile.path);
      await db.close();
    });

    test('Reopen connection', () async {
      var db = Db(defaultUri);

      await db.open(
          secure: true,
          tlsCAFile: caCertFile.path,
          tlsCertificateKeyFile: pemFile.path);
      await db.close();

      await db.open(
          secure: true,
          tlsCAFile: caCertFile.path,
          tlsCertificateKeyFile: pemFile.path);
      await db.close();
    });
  });
}
