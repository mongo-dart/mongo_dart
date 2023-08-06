part of '../../crud_test.dart';

Future findTest() async {
  late MongoClient client;
  late MongoDatabase db;
  List<String> usedCollectionNames = [];

  group('Find', () {
    setUp(() async {
      client = MongoClient(defaultUri);
      db = await initializeDatabase(client);
    });

    tearDown(() async {
      await cleanupDatabase(client);
    });

    group('- Find Simple', () {
      test('Select all', () async {
        await findSimpleSelection(db, usedCollectionNames);
      });
      test('Select with document', () async {
        await findSimpleSelection(db, usedCollectionNames);
      });
    });

    /*  group('Insert many', () {
      test('', () async {
        await insertManyDocumentsWithoutIdRaw(db, usedCollectionNames);
      });
    }); */
  });
  tearDownAll(() async {
    await client.connect();
    db = client.db();
    await Future.forEach(usedCollectionNames,
        (String collectionName) => db.collection(collectionName).drop());
    await client.close();
  });
}
