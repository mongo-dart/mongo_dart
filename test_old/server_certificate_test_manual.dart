import 'dart:io';

import 'package:mongo_dart/src/core/error/connection_exception.dart';
import 'package:mongo_dart/src/mongo_client.dart';
import 'package:mongo_dart/src/mongo_client_options.dart';
import 'package:test/test.dart';

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
      var client = MongoClient(defaultUri);

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

    test('Must be run all together', () async {
      var options = MongoClientOptions();
      options.tls = true;
      options.tlsCAFile = caCertFile.path;
      var client = MongoClient(defaultUri, mongoClientOptions: options);
      await client.connect();
      await client.close();

      // Check to avoid problems with the
      // "certificate already in hash table error"
      //test('Connect no problems with cert', () async {
      options = MongoClientOptions();
      options.tls = true;
      options.tlsCAFile = caCertFile.path;
      client = MongoClient(defaultUri, mongoClientOptions: options);
      await client.connect();
      await client.close();
      //});

      // same isolate, once connected, the certificate stays in cache
      //test('Reopen connection', () async {
      options = MongoClientOptions();
      options.tls = true;
      client = MongoClient(defaultUri, mongoClientOptions: options);
      await client.connect();
      await client.close();

      //});

      // The certificate stays in cache even for a different server
      // (with a certificate from the same authority)
      //test('Connects with no problems on a different server', () async {
      options = MongoClientOptions();
      options.tls = true;
      client = MongoClient(defaultUri2, mongoClientOptions: options);
      await client.connect();
      await client.close();
    });
  });
}
