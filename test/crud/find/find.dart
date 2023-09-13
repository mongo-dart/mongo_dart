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
      test('Select with FilterExpression', () async {
        await findSimpleSelectionFilter(db, usedCollectionNames);
      });
      test('Select with QueryExpression', () async {
        await findSimpleSelectionQuery(db, usedCollectionNames);
      });
    });
    group('- Find Default', () {
      test('Select all', () async {
        await findDefault(db, usedCollectionNames);
      });
      test('Select with Query', () async {
        await findDefaultSelectionQuery(db, usedCollectionNames);
      });
      test('Select with Query on embedded field', () async {
        await findDefaultEmbeddedQuery(db, usedCollectionNames);
      });
      test('Select with Query multiple documents', () async {
        await findDefaultMultipleQuery(db, usedCollectionNames);
      });
      test('Select with Query different operators', () async {
        await findDefaultQueries(db, usedCollectionNames);
      });
      test('Select with Query range', () async {
        await findDefaultRangeQuery(db, usedCollectionNames);
      });
      test('Select with Query simple and', () async {
        await findDefaultAndQuery(db, usedCollectionNames);
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
