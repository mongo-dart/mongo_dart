import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/mongo_client.dart';

void main() async {
  var client = MongoClient('mongodb://127.0.0.1/mongo_dart-test');
  await client.connect();
  var db = client.db();
  ///// Simple update
  var coll = db.collection('collection-for-save');
  await coll.remove({});
  var toInsert = <Map<String, dynamic>>[
    {'name': 'a', 'value': 10},
    {'name': 'b', 'value': 20},
    {'name': 'c', 'value': 30},
    {'name': 'd', 'value': 40}
  ];
  await coll.insertAll(toInsert);
  var v1 = await coll.findOne({'name': 'c'});
  if (v1 == null) {
    print('Record not found');
    await client.close();
    return;
  }
  print('Record c: $v1');
  v1['value'] = 31;
  await coll.insertOne(v1);
  var v2 = await coll.findOne({'name': 'c'});
  print('Record c after update: $v2');

  /////// Field level update
  coll = db.collection('collection-for-save');
  await coll.remove({});
  toInsert = <Map<String, dynamic>>[
    {'name': 'a', 'value': 10},
    {'name': 'b', 'value': 20},
    {'name': 'c', 'value': 30},
    {'name': 'd', 'value': 40}
  ];
  await coll.insertAll(toInsert);
  v1 = await coll.findOne({'name': 'c'});
  print('Record c: $v1');
  await coll.update(where.eq('name', 'c'), modify.set('value', 31));
  v2 = await coll.findOne({'name': 'c'});
  print('Record c after field level update: $v2');

  //// Field level increment

  coll = db.collection('collection-for-save');
  await coll.remove({});
  toInsert = <Map<String, dynamic>>[
    {'name': 'a', 'value': 10},
    {'name': 'b', 'value': 20},
    {'name': 'c', 'value': 30},
    {'name': 'd', 'value': 40}
  ];
  await coll.insertAll(toInsert);
  v1 = await coll.findOne({'name': 'c'});
  print('Record c: $v1');
  await coll.update(where.eq('name', 'c'), modify.inc('value', 1));
  v2 = await coll.findOne({'name': 'c'});
  print('Record c after field level increment by one: $v2');
  await client.close();
}
