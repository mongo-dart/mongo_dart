part of '../../crud_test.dart';

///
Future findDefault(MongoDatabase db, List<String> usedColletions) async {
  var collectionName = getRandomCollectionName(usedColletions);
  var collection = db.collection(collectionName);
  var (_, MongoDocument result, _, _) = await insertBio(collection);
  expect(result, containsPair('ok', 1.0));

  var findList = await collection.find(emptyMongoDocument).toList();

  expect(findList.length, 10);
  expect(findList.first['_id'], 1);
}

///

///
Future findDefaultSelectionQuery(
    MongoDatabase db, List<String> usedColletions) async {
  var collectionName = getRandomCollectionName(usedColletions);
  var collection = db.collection(collectionName);
  var (_, MongoDocument result, _, _) = await insertBio(collection);
  expect(result, containsPair('ok', 1.0));

  var findList = await collection.findQuery(where..$eq('_id', 5)).toList();

  expect(findList.length, 1);
  expect(findList.first['_id'], 5);
}

///
Future findDefaultEmbeddedQuery(
    MongoDatabase db, List<String> usedColletions) async {
  var collectionName = getRandomCollectionName(usedColletions);
  var collection = db.collection(collectionName);
  var (_, MongoDocument result, _, _) = await insertBio(collection);
  expect(result, containsPair('ok', 1.0));

  var findList =
      await collection.findQuery(where..$eq('name.last', 'Hopper')).toList();

  expect(findList.length, 1);
  expect(findList.first['_id'], 3);
}

///
Future findDefaultMultipleQuery(
    MongoDatabase db, List<String> usedColletions) async {
  var collectionName = getRandomCollectionName(usedColletions);
  var collection = db.collection(collectionName);
  var (_, MongoDocument result, _, _) = await insertBio(collection);
  expect(result, containsPair('ok', 1.0));

  var findList = await collection
      .findQuery(
          where..$in('_id', [5, ObjectId.parse('51df07b094c6acd67e492f41')]))
      .toList();

  expect(findList.length, 2);
  expect(findList.first['_id'], 5);
}

Future findDefaultQueries(MongoDatabase db, List<String> usedColletions) async {
  var collectionName = getRandomCollectionName(usedColletions);
  var collection = db.collection(collectionName);
  var (_, MongoDocument result, _, _) = await insertBio(collection);
  expect(result, containsPair('ok', 1.0));

  var findList = await collection
      .findQuery(where..$gt('birth', DateTime(1950, 1, 1)))
      .toList();

  expect(findList.length, 3);
  expect(findList.first['_id'], 6);

  findList =
      await collection.findQuery(where..$regex('name.last', '^N')).toList();

  expect(findList.length, 1);
  expect(findList.first['_id'], 4);

  findList = await collection
      .findQuery(where
        ..raw({
          'name.last': {r'$regex': '^N'}
        }))
      .toList();

  expect(findList.length, 1);
  expect(findList.first['_id'], 4);
}

Future findDefaultRangeQuery(
    MongoDatabase db, List<String> usedColletions) async {
  var collectionName = getRandomCollectionName(usedColletions);
  var collection = db.collection(collectionName);
  var (_, MongoDocument result, _, _) = await insertBio(collection);
  expect(result, containsPair('ok', 1.0));

  var findList = await collection
      .findQuery(
          where..inRange('birth', DateTime(1940, 1, 1), DateTime(1960, 1, 1)))
      .toList();

  expect(findList.length, 3);
  expect(findList.first['_id'], 6);
}

Future findDefaultAndQuery(
    MongoDatabase db, List<String> usedColletions) async {
  var collectionName = getRandomCollectionName(usedColletions);
  var collection = db.collection(collectionName);
  var (_, MongoDocument result, _, _) = await insertBio(collection);
  expect(result, containsPair('ok', 1.0));

  var findList = await collection
      .findQuery(where
        ..$gt('birth', DateTime(1920, 1, 1))
        ..notExists('death'))
      .toList();

  expect(findList.length, 3);
  expect(findList.first['_id'], 6);
}
