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

  var (_, result2, _, _) =
      await collection.insertOne({'item': "card", 'qty': 15});
  //MongoDocument result2 = doc.serverResponses.first;

  expect(result, containsPair('ok', 1.0));
  expect(result2, containsPair('ok', 1.0));
  expect(result, containsPair('n', 1));
  expect(result2, containsPair('n', 1));
}
