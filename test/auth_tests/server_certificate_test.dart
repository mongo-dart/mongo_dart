// ignore_for_file: unused_local_variable

import 'package:universal_io/io.dart';

import 'package:test/test.dart';
import 'package:mongo_dart/mongo_dart.dart';

// Run server1 with these parameters:
// mongod --port 27032  --dbpath <your-data-path> --oplogSize 128
//  --tlsMode requireTLS --tlsCertificateKeyFile
//  <your-mongo-dart-folder>/test/certificates_for_testing/server1.pem
//
// Run server2 with these parameters:
// mongod --port 27033  --dbpath <your-data-path-2> --oplogSize 128
//  --tlsMode requireTLS --tlsCertificateKeyFile
//  <your-mongo-dart-folder>/test/certificates_for_testing/server2.pem
const dbName = 'mongo-dart-server-cert';
const dbServerName = 'server1';
const defaultUri = 'mongodb://127.0.0.1:27032/$dbName';

const dbServerName2 = 'server2';
const defaultUri2 = 'mongodb://127.0.0.1:27033/$dbName';

void main() async {
  bool serverfound = false;
  bool isVer3_2 = false;
  bool isVer3_6 = false;
  bool isNoMoreMongodbCR = false;
  var caCertFile =
      File('test/certificates_for_testing/mongo-test-ca-full-chain.crt');

  Future<bool> findServer(String uriString) async {
    var db = Db(uriString);
    Uri uri = Uri.parse(uriString);
    try {
      await db.open(secure: true, tlsCAFile: caCertFile.path);
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
      await db.open(secure: true, tlsCAFile: caCertFile.path);
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

  group('Server certificate', () {
    if (!serverfound) {
      return;
    }
    test('No certificate, no connection', () async {
      var db = Db(defaultUri);

      try {
        await db.open(secure: true);
        // If the test has been already run, the certificate
        // already in hash Table
        expect(true, isTrue);
      } on ConnectionException {
        expect(true, isTrue);
      } catch (e) {
        expect(true, isFalse);
      } finally {
        await db.close();
      }
    });

    test('Must be run all together', () async {
      var db = Db(defaultUri);

      await db.open(secure: true, tlsCAFile: caCertFile.path);
      await db.close();

      // Check to avoid problems with the
      // "certificate already in hash table error"
      //test('Connect no problems with cert', () async {
      db = Db(defaultUri);

      await db.open(secure: true, tlsCAFile: caCertFile.path);
      await db.close();
      //});

      // same isolate, once connected, the certificate stays in cache
      //test('Reopen connection', () async {
      db = Db(defaultUri);

      await db.open(secure: true);
      await db.close();

      await db.open(secure: true, tlsCAFile: caCertFile.path);
      await db.close();
      //});

      // The certificate stays in cache even for a different server
      // (with a certificate from the same authority)
      //test('Connects with no problems on a different server', () async {
      db = Db(defaultUri2);

      await db.open(secure: true);
      await db.close();
    });
  });
}
