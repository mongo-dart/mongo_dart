import 'package:mongo_dart/src/mongo_client.dart';
import 'package:mongo_dart/src/database/mongo_database.dart';
import 'package:test/test.dart';

const dbName = 'test-mongo-dart';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

late MongoClient client;
late MongoDatabase db;

void main() async {
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
        client.topology?.servers.first.refreshStatus();
        client.topology?.servers.first.refreshStatus();
        await Future.delayed(Duration(seconds: 2));
        client.topology?.servers.first.refreshStatus();
        await client.topology?.servers.first.refreshStatus();
        expect(
            client.topology?.servers.first.connectionPool.connectionsNumber, 2);
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
