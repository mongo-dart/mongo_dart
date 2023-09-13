part of '../../crud_test.dart';

Future<MongoDocument> _insertFruits(
    MongoDatabase db, String collectionName) async {
  return db.runCommand({
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
}

///
Future findSimple(MongoDatabase db, List<String> usedColletions) async {
  var collectionName = getRandomCollectionName(usedColletions);
  var collection = db.collection(collectionName);
  var result = await _insertFruits(db, collectionName);
  expect(result, containsPair('ok', 1.0));

  var findList = await collection.find(emptyMongoDocument).toList();

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
  var result = await _insertFruits(db, collectionName);
  expect(result, containsPair('ok', 1.0));

  var findList = await collection.find({
    'qty': {r'$gt': 4}
  }).toList();

  expect(findList.length, 2);
  expect(findList.first, {"_id": "apples", "qty": 5});
  expect(findList.last, {"_id": "bananas", "qty": 7});
}

///
Future findSimpleSelectionFilter(
    MongoDatabase db, List<String> usedColletions) async {
  var collectionName = getRandomCollectionName(usedColletions);
  var collection = db.collection(collectionName);
  var result = await _insertFruits(db, collectionName);
  expect(result, containsPair('ok', 1.0));

  var findList = await collection
      .find(FilterExpression()
        ..addFieldOperator(FieldExpression(
            'qty', OperatorExpression(op$gt, ValueExpression.create(4)))))
      .toList();

  expect(findList.length, 2);
  expect(findList.first, {"_id": "apples", "qty": 5});
  expect(findList.last, {"_id": "bananas", "qty": 7});
}

///
Future findSimpleSelectionQuery(
    MongoDatabase db, List<String> usedColletions) async {
  var collectionName = getRandomCollectionName(usedColletions);
  var collection = db.collection(collectionName);
  var result = await _insertFruits(db, collectionName);
  expect(result, containsPair('ok', 1.0));

  var findList = await collection.findQuery(where..$gt('qty', 4)).toList();

  expect(findList.length, 2);
  expect(findList.first, {"_id": "apples", "qty": 5});
  expect(findList.last, {"_id": "bananas", "qty": 7});
}
