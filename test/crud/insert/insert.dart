part of '../../crud_test.dart';

Future insertTest() async {
  late MongoClient client;
  late MongoDatabase db;
  List<String> usedCollectionNames = [];

  group('Insert', () {
    setUp(() async {
      client = MongoClient(defaultUri);
      db = await initializeDatabase(client);
    });

    tearDown(() async {
      await cleanupDatabase(client);
    });

    group('Insert One', () {
      test('', () async {
        await insertDocumentWithoutIdRaw(db, usedCollectionNames);
      });
    });

    group('Insert many', () {
      test('', () async {
        await insertManyDocumentsWithoutIdRaw(db, usedCollectionNames);
      });
    });
  });
  tearDownAll(() async {
    await client.connect();
    db = client.db();
    await Future.forEach(usedCollectionNames,
        (String collectionName) => db.collection(collectionName).drop());
    await client.close();
  });
}
