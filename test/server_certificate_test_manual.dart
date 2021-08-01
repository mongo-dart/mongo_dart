import 'dart:io';

import 'package:test/test.dart';
import 'package:mongo_dart/mongo_dart.dart';

// Insert in your hosts file:
// 127.0.0.1 server1
// 127.0.0.1 server2
//
// Run server1 with these parameters:
// mongod --port 27017  --dbpath <your-data-path> --oplogSize 128
//  --tlsMode requireTLS --tlsCertificateKeyFile
//  <your-mongo-dart-folder>/test/certificates_for_testing/server1.pem
//
// Run server2 with these parameters:
// mongod --port 27018  --dbpath <your-data-path-2> --oplogSize 128
//  --tlsMode requireTLS --tlsCertificateKeyFile
//  <your-mongo-dart-folder>/test/certificates_for_testing/server2.pem
const dbName = 'mongo-dart-server-cert';
const dbServerName = 'server1';
const defaultUri = 'mongodb://$dbServerName:27017/$dbName';

const dbServerName2 = 'server2';
const defaultUri2 = 'mongodb://$dbServerName2:27018/$dbName';

void main() {
  group('Server certificate', () {
    var caCertFile =
        File('test/certificates_for_testing/mongo-test-ca-full-chain.crt');

    test('No certificate, no connection', () async {
      var db = Db(defaultUri);

      try {
        await db.open(secure: true);
        expect(true, isFalse);
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
