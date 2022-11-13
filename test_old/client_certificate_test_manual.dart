import 'dart:io';

import 'package:mongo_dart/src/core/error/connection_exception.dart';
import 'package:mongo_dart/src/mongo_client.dart';
import 'package:mongo_dart/src/mongo_client_options.dart';
import 'package:test/test.dart';

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
      var client = MongoClient(defaultUri,
          mongoClientOptions: MongoClientOptions()..tls = true);

      try {
        await client.connect();
        expect(true, isFalse);
      } on ConnectionException {
        expect(true, isTrue);
      } catch (e) {
        expect(true, isFalse);
      } finally {
        await client.close();
      }
    });

    test('Should not be able to connect missing key file', () async {
      var client = MongoClient(defaultUri,
          mongoClientOptions: MongoClientOptions()
            ..tls = true
            ..tlsCAFile = caCertFile.path);
      try {
        await client.connect();
        expect(true, isFalse);
      } on ConnectionException {
        expect(true, isTrue);
      } catch (e) {
        expect(true, isFalse);
      } finally {
        await client.close();
      }
    });

    // Check to avoid problems with the
    // "certificate already in hash table error"
    test(
        'Should not be able to connect missing key file, CA File given 2 times',
        () async {
      var client = MongoClient(defaultUri,
          mongoClientOptions: MongoClientOptions()
            ..tls = true
            ..tlsCAFile = caCertFile.path);
      try {
        await client.connect();
        expect(true, isFalse);
      } on ConnectionException {
        expect(true, isTrue);
      } catch (e) {
        expect(true, isFalse);
      } finally {
        await client.close();
      }
    });

    test('Wrong pem file', () async {
      var client = MongoClient(defaultUri,
          mongoClientOptions: MongoClientOptions()
            ..tls = true
            ..tlsCAFile = caCertFile.path
            ..tlsCertificateKeyFile = wrongPemFile.path);
      try {
        await client.connect();
        await client.close();
        expect(true, isFalse);
      } on ConnectionException {
        expect(true, isTrue);
      } catch (e) {
        expect(true, isFalse);
      } finally {
        await client.close();
      }
    });
    test('Connect no problems with cert', () async {
      var client = MongoClient(defaultUri,
          mongoClientOptions: MongoClientOptions()
            ..tls = true
            ..tlsCAFile = caCertFile.path
            ..tlsCertificateKeyFile = pemFile.path);
      await client.connect();
      await client.close();
    });

    test('Reopen connection', () async {
      var client = MongoClient(defaultUri,
          mongoClientOptions: MongoClientOptions()
            ..tls = true
            ..tlsCAFile = caCertFile.path
            ..tlsCertificateKeyFile = pemFile.path);
      await client.connect();
      await client.close();

      await client.connect();
      await client.close();
    });
  });
}
