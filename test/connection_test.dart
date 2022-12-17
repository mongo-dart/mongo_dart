import 'dart:async';

import 'package:logging/logging.dart';
import 'package:mongo_dart/src/mongo_client.dart';
import 'package:mongo_dart/src/database/mongo_database.dart';
import 'package:mongo_dart/src/mongo_client_options.dart';
import 'package:mongo_dart/src/utils/mongo_db_error.dart';
import 'package:test/test.dart';

const dbName = 'test-mongo-dart';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

late MongoClient client;
late MongoDatabase db;

void main() async {
  hierarchicalLoggingEnabled = true;
  Logger('Mongo Connection Test').level = Level.ALL;
  void listener(LogRecord r) {
    var name = r.loggerName;
    print('${r.time}: $name: ${r.message}');
  }

  Logger.root.onRecord.listen(listener);

  Future initializeDatabase() async {
    client = MongoClient(defaultUri);
    await client.connect();
    db = client.db();
  }

  Future cleanupDatabase() async {
    await client.close();
  }

  group('Connections', () {
    group('Connection', () {
      //var cannotRunTests = false;
      //var running4_4orGreater = false;
      var running4_2orGreater = false;

      //var isReplicaSet = false;
      //var isStandalone = false;
      //var isSharded = false;

      setUp(() async {
        await initializeDatabase();
        if (!db.server.serverCapabilities.supportsOpMsg) {
          //cannotRunTests = true;
        }
        var serverFcv = db.server.serverCapabilities.fcv ?? '0.0';
        if (serverFcv.compareTo('4.4') != -1) {
          //running4_4orGreater = true;
        }
        if (serverFcv.compareTo('4.2') != -1) {
          running4_2orGreater = true;
        }
        //isReplicaSet = db.server.serverCapabilities.isReplicaSet;
        //isStandalone = db.server.serverCapabilities.isStandalone;
        //isSharded = db.server.serverCapabilities.isShardedCluster;
      });

      tearDown(() async {
        await cleanupDatabase();
      });

      test('One connection', () async {
        expect(running4_2orGreater, isTrue);
        await client.topology?.servers.first.refreshStatus();
        expect(
            client.topology?.servers.first.connectionPool.connectionsNumber, 1);
      });

      test('Sequential connections', () async {
        expect(running4_2orGreater, isTrue);
        await client.topology?.servers.first.refreshStatus();
        await client.topology?.servers.first.refreshStatus();
        await client.topology?.servers.first.refreshStatus();
        await client.topology?.servers.first.refreshStatus();
        expect(
            client.topology?.servers.first.connectionPool.connectionsNumber, 1);
      });

      test('Concurrent connections', () async {
        expect(running4_2orGreater, isTrue);
        unawaited(client.topology?.servers.first.refreshStatus().then(
            expectAsync1((_) {
          /* Check the value in here if you want. */
        }), onError: (err) {
          // It's enough to just fail!
          fail('error !');
        }));
        unawaited(client.topology?.servers.first.refreshStatus().then(
            expectAsync1((_) {
          /* Check the value in here if you want. */
        }), onError: (err) {
          // It's enough to just fail!
          fail('error !');
        }));
        await Future.delayed(Duration(seconds: 2));
        unawaited(client.topology?.servers.first.refreshStatus().then(
            expectAsync1((_) {
          /* Check the value in here if you want. */
        }), onError: (err) {
          // It's enough to just fail!
          fail('error !');
        }));
        await client.topology?.servers.first.refreshStatus();
        expect(
            client.topology?.servers.first.connectionPool.connectionsNumber, 2);
      });
    });
    group('Connection Pool', () {
      group('Max Size', () {
        Future<bool> checkVersion(MongoClient client) async {
          await client.connect();
          var db = client.db();
          var serverFcv = db.server.serverCapabilities.fcv ?? '0.0';

          return serverFcv.compareTo('4.2') != -1;
        }

        setUp(() async {});

        tearDown(() async {
          await cleanupDatabase();
        });

        test('options parm', () async {
          var options = MongoClientOptions()..maxPoolSize = 5;
          client = MongoClient(defaultUri, mongoClientOptions: options);
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          await client.topology?.servers.first.refreshStatus();
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              1);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 5);
        });
        test('uri - parm', () async {
          client = MongoClient('$defaultUri?maxPoolSize=2');
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              2);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 2);
        });
        test('options && URI parms', () async {
          var options = MongoClientOptions()..maxPoolSize = 2;
          client = MongoClient('$defaultUri?maxPoolSize=5',
              mongoClientOptions: options);
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              3);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 5);
        });

        test('Sequential connections', () async {
          client = MongoClient('$defaultUri?maxPoolSize=2');
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          await client.topology?.servers.first.refreshStatus();
          await client.topology?.servers.first.refreshStatus();
          await client.topology?.servers.first.refreshStatus();
          await client.topology?.servers.first.refreshStatus();
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              1);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 2);
        });

        test('Concurrent connections', () async {
          client = MongoClient('$defaultUri?maxPoolSize=3');
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              3);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 3);
        });
      });

      group('Min Size', () {
        Future<bool> checkVersion(MongoClient client) async {
          await client.connect();
          var db = client.db();
          var serverFcv = db.server.serverCapabilities.fcv ?? '0.0';

          return serverFcv.compareTo('4.2') != -1;
        }

        setUp(() async {});

        tearDown(() async {
          await cleanupDatabase();
        });

        test('One connection - min pool - options', () async {
          var options = MongoClientOptions()..minPoolSize = 5;
          client = MongoClient(defaultUri, mongoClientOptions: options);
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          await client.topology?.servers.first.refreshStatus();
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              5);
        });
        test('One connection - min pool - uri', () async {
          client = MongoClient('$defaultUri?minPoolSize=4');
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          await client.topology?.servers.first.refreshStatus();
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              4);
        });
        test('One connection - min pool - options && URI', () async {
          var options = MongoClientOptions()..minPoolSize = 5;
          client = MongoClient('$defaultUri?minPoolSize=4',
              mongoClientOptions: options);
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          await client.topology?.servers.first.refreshStatus();
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              4);
        });

        test('Sequential connections', () async {
          client = MongoClient('$defaultUri?minPoolSize=2');
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          await client.topology?.servers.first.refreshStatus();
          await client.topology?.servers.first.refreshStatus();
          await client.topology?.servers.first.refreshStatus();
          await client.topology?.servers.first.refreshStatus();
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              2);
        });

        test('Concurrent connections', () async {
          client = MongoClient('$defaultUri?minPoolSize=2');
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              5);
        });
      });

      group('Max && Min Size', () {
        Future<bool> checkVersion(MongoClient client) async {
          await client.connect();
          var db = client.db();
          var serverFcv = db.server.serverCapabilities.fcv ?? '0.0';

          return serverFcv.compareTo('4.2') != -1;
        }

        setUp(() async {});

        tearDown(() async {
          await cleanupDatabase();
        });

        test('options parm', () async {
          var options = MongoClientOptions()
            ..maxPoolSize = 5
            ..minPoolSize = 3;
          client = MongoClient(defaultUri, mongoClientOptions: options);
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          await client.topology?.servers.first.refreshStatus();
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              3);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 5);
          expect(client.topology?.servers.first.connectionPool.minPoolSize, 3);
        });
        test('uri - parm', () async {
          client = MongoClient('$defaultUri?maxPoolSize=2&minPoolSize=1');
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              2);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 2);
          expect(client.topology?.servers.first.connectionPool.minPoolSize, 1);
        });
        test('options && URI parms', () async {
          var options = MongoClientOptions()
            ..maxPoolSize = 2
            ..minPoolSize = 1;
          client = MongoClient('$defaultUri?maxPoolSize=5&minPoolSize=2',
              mongoClientOptions: options);
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              3);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 5);
          expect(client.topology?.servers.first.connectionPool.minPoolSize, 2);
        });

        test('Sequential connections', () async {
          client = MongoClient('$defaultUri?maxPoolSize=2');
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          await client.topology?.servers.first.refreshStatus();
          await client.topology?.servers.first.refreshStatus();
          await client.topology?.servers.first.refreshStatus();
          await client.topology?.servers.first.refreshStatus();
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              1);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 2);
          expect(client.topology?.servers.first.connectionPool.minPoolSize, 0);
        });

        test('Concurrent connections', () async {
          client = MongoClient('$defaultUri?maxPoolSize=3&minPoolSize=2');
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              3);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 3);
          expect(client.topology?.servers.first.connectionPool.minPoolSize, 2);
        });
        test('Auto fix min', () async {
          client = MongoClient('$defaultUri?maxPoolSize=3&minPoolSize=4');
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              3);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 3);
          expect(client.topology?.servers.first.connectionPool.minPoolSize, 3);
        });
        test('Auto fix min 2', () async {
          client = MongoClient('$defaultUri?minPoolSize=4&maxPoolSize=3');
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              3);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 3);
          expect(client.topology?.servers.first.connectionPool.minPoolSize, 3);
        });
        test('Auto fix min 3', () async {
          var options = MongoClientOptions()..maxPoolSize = 3;
          client = MongoClient('$defaultUri?minPoolSize=4',
              mongoClientOptions: options);
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              3);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 3);
          expect(client.topology?.servers.first.connectionPool.minPoolSize, 3);
        });
        test('Auto fix min 4', () async {
          var options = MongoClientOptions()..minPoolSize = 4;
          client = MongoClient('$defaultUri?maxPoolSize=3',
              mongoClientOptions: options);
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              3);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 3);
          expect(client.topology?.servers.first.connectionPool.minPoolSize, 3);
        });
      });

      group('Wait Queue Timeout', () {
        Future<bool> checkVersion(MongoClient client) async {
          await client.connect();
          var db = client.db();
          var serverFcv = db.server.serverCapabilities.fcv ?? '0.0';

          return serverFcv.compareTo('4.2') != -1;
        }

        setUp(() async {});

        tearDown(() async {
          await cleanupDatabase();
        });

        test('options parm', () async {
          var options = MongoClientOptions()
            ..waitQueueTimeoutMS = 5
            ..maxPoolSize = 3;
          client = MongoClient(defaultUri, mongoClientOptions: options);
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          await client.topology?.servers.first.refreshStatus();
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              1);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 3);
          expect(
              client.topology?.servers.first.connectionPool.waitQueueTimeoutMS,
              5);
        });
        test('uri - parm', () async {
          client =
              MongoClient('$defaultUri?maxPoolSize=2&waitQueueTimeoutMS=5');
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            expect(
                client.topology?.servers.first.connectionPool.connectionsNumber,
                2); /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            expect(
                client.topology?.servers.first.connectionPool.connectionsNumber,
                2);
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then((_) {
            expect(true, isFalse);
          }, onError: (err) {
            // It's enough to just fail!
            expect(err.runtimeType, MongoDbError);
          }));

          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              2);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 2);
          expect(
              client.topology?.servers.first.connectionPool.waitQueueTimeoutMS,
              5);
        });
        test('options && URI parms', () async {
          var options = MongoClientOptions()
            ..maxPoolSize = 2
            ..waitQueueTimeoutMS = 5;
          client = MongoClient('$defaultUri?maxPoolSize=5&waitQueueTimeoutMS=5',
              mongoClientOptions: options);
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            /* Check the value in here if you want. */
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              3);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 5);
          expect(
              client.topology?.servers.first.connectionPool.waitQueueTimeoutMS,
              5);
        });

        test('Sequential connections', () async {
          client =
              MongoClient('$defaultUri?maxPoolSize=2&waitQueueTimeoutMS=5');
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          await client.topology?.servers.first.refreshStatus();
          await client.topology?.servers.first.refreshStatus();
          await client.topology?.servers.first.refreshStatus();
          await client.topology?.servers.first.refreshStatus();
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              1);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 2);
          expect(
              client.topology?.servers.first.connectionPool.waitQueueTimeoutMS,
              5);
        });

        test('Concurrent connections', () async {
          client =
              MongoClient('$defaultUri?maxPoolSize=3&waitQueueTimeoutMS=100');
          var running4_2orGreater = await checkVersion(client);
          expect(running4_2orGreater, isTrue);
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            expect(
                client.topology?.servers.first.connectionPool.connectionsNumber,
                3);
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            expect(
                client.topology?.servers.first.connectionPool.connectionsNumber,
                3);
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            expect(
                client.topology?.servers.first.connectionPool.connectionsNumber,
                3);
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            expect(
                client.topology?.servers.first.connectionPool.connectionsNumber,
                3);
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          unawaited(client.topology?.servers.first.refreshStatus().then(
              expectAsync1((_) {
            expect(
                client.topology?.servers.first.connectionPool.connectionsNumber,
                3);
          }), onError: (err) {
            // It's enough to just fail!
            fail('error !');
          }));
          expect(
              client.topology?.servers.first.connectionPool.connectionsNumber,
              3);
          expect(client.topology?.servers.first.connectionPool.maxPoolSize, 3);
          expect(
              client.topology?.servers.first.connectionPool.waitQueueTimeoutMS,
              100);
        });
      });
    });
  });

  tearDownAll(() async {
    /*  await client.connect();
    db = client.db();
    await Future.forEach(usedCollectionNames,
        (String collectionName) => db.collection(collectionName).drop());
    await client.close(); */
  });
}
