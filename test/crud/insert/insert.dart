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
    test('', () async {
      await insertDocumentWithoutIdRaw(db, usedCollectionNames);
    });

/* 
    group('InsertOne', () {
      test('Insert Document Without Id', insertDocumentWithoutIdRaw);
    }); */
    group('DbCollection tests:', () {
      //test('testAuthComponents', testAuthComponents);
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
