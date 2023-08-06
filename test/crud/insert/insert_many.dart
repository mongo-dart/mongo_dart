part of '../../crud_test.dart';

/// Insert a Document without Specifying an _id Field
/// In the following example, the document passed to the insertOneRaw()
/// method does not contain the _id field:
Future insertManyDocumentsWithoutIdRaw(
    MongoDatabase db, List<String> usedColletions) async {
  var collectionName = getRandomCollectionName(usedColletions);
  var collection = db.collection(collectionName);
  var result = await db.runCommand({
    'insert': "users",
    'documents': [
      {'user': "ijk123", 'status': "A"},
      {'user': "xyz123", 'status': "P"},
      {'user': "mop123", 'status': "P"}
    ],
    'ordered': false,
    'writeConcern': {'w': "majority", 'wtimeout': 5000}
  });

  var (_, serverResponse, _, _) = await collection.insertMany([
    {'_id': 2, 'user': "ijk123", 'status': "A"},
    {'_id': 3, 'user': "xyz123", 'status': "P"},
    {'_id': 4, 'user': "mop123", 'status': "P"}
  ]);
  MongoDocument result2 = serverResponse;

  expect(result, containsPair('ok', 1.0));
  expect(result2, containsPair('ok', 1.0));
  expect(result, containsPair('n', 3));
  expect(result2, containsPair('n', 3));
}
