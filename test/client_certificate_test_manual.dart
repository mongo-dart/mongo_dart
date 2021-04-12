import 'dart:io';

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

const defaultUri = 'mongodb://$dbServerName:27017/$dbName';

void main() {
  group('Client certificate', () {
    var caCertFile = File('${Directory.current.path}'
        '/test/certificates_for_testing/mongo-test-ca-full-chain.crt');
    var pemFile = File('${Directory.current.path}'
        '/test/certificates_for_testing/client.mongo.pem');
    var wrongPemFile = File('test/certificates_for_testing/client.mongo.crt');

    test('Should not be able to connect missing key file and CA file',
        () async {
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

    test('Should not be able to connect missing key file', () async {
      var db = Db(defaultUri);

      try {
        await db.open(secure: true, tlsCAFile: caCertFile.path);
        expect(true, isFalse);
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
        expect(true, isFalse);
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
