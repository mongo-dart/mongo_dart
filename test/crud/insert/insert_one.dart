part of '../../crud_test.dart';

/// Insert a Document without Specifying an _id Field
/// In the following example, the document passed to the insertOneRaw()
/// method does not contain the _id field:
Future insertDocumentWithoutIdRaw(
    MongoDatabase db, List<String> usedColletions) async {
  var collectionName = getRandomCollectionName(usedColletions);
  var collection = db.collection(collectionName);
  var result = await db.runCommand({
    'insert': collectionName,
    'documents': [
      {'item': "card", 'qty': 15}
    ],
    'ordered': true,
    'writeConcern': WriteConcern.majority.asMap(db.server.serverStatus),
    'bypassDocumentValidation': false,
    'comment': 'Test comment'
  });

  var doc = await collection.insertOne({'item': "card", 'qty': 15});
  MongoDocument result2 = doc.serverResponses.first;

  expect(result.length, 2);
  expect(result.length, result2.length);
  expect(result, {'n': 1, 'ok': 1.0});
  expect(result, result2);
}
