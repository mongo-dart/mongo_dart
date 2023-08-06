part of '../../crud_test.dart';

///
Future findSimple(MongoDatabase db, List<String> usedColletions) async {
  var collectionName = getRandomCollectionName(usedColletions);
  var collection = db.collection(collectionName);
  var result = await db.runCommand({
    'insert': collectionName,
    'documents': [
      {"_id": "apples", "qty": 5},
      {"_id": "bananas", "qty": 7},
      {
        "_id": "oranges",
        "qty": {"in stock": 8, "ordered": 12}
      },
      {"_id": "avocados", "qty": "fourteen"},
    ],
    'ordered': true,
    'writeConcern': WriteConcern.majority.asMap(db.server.serverStatus),
    'bypassDocumentValidation': false,
    'comment': 'Test comment'
  });
  expect(result, containsPair('ok', 1.0));

  var findList = await collection.findOriginal().toList();

  expect(findList.length, 4);
  expect(findList.first, {"_id": "apples", "qty": 5});
  expect(
    findList.last,
    {"_id": "avocados", "qty": "fourteen"},
  );
}

///
Future findSimpleSelection(
    MongoDatabase db, List<String> usedColletions) async {
  var collectionName = getRandomCollectionName(usedColletions);
  var collection = db.collection(collectionName);
  var result = await db.runCommand({
    'insert': collectionName,
    'documents': [
      {"_id": "apples", "qty": 5},
      {"_id": "bananas", "qty": 7},
      {
        "_id": "oranges",
        "qty": {"in stock": 8, "ordered": 12}
      },
      {"_id": "avocados", "qty": "fourteen"},
    ],
    'ordered': true,
    'writeConcern': WriteConcern.majority.asMap(db.server.serverStatus),
    'bypassDocumentValidation': false,
    'comment': 'Test comment'
  });
  expect(result, containsPair('ok', 1.0));

  var findList = await collection.findOriginal({
    'qty': {r'$gt': 4}
  }).toList();

  expect(findList.length, 2);
  expect(findList.first, {"_id": "apples", "qty": 5});
  expect(findList.last, {"_id": "bananas", "qty": 7});
}
