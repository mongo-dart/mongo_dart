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

  MongoDocument result2;
  try {
    result2 = await collection.insertOneRaw({'item': "card", 'qty': 15});
  } catch (e) {
    print(e);
    return;
  }

  expect(result.length, 2);
  expect(result.length, result2.length);
  expect(result['acknowledged'], result2['acknowledged']);
  expect(result['insertedId'] != result2['insertedId'], isTrue);
}
