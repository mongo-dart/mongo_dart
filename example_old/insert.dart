import 'package:mongo_dart/src/database/mongo_collection.dart';
import 'package:mongo_dart/src/mongo_client.dart';
import 'package:mongo_dart/src/commands/parameters/write_concern.dart';

void main() async {
  var client = MongoClient('mongodb://127.0.0.1/test_insert');
  await client.connect();
  final db = client.db();
  var stopwatch = Stopwatch()..start();
  MongoCollection test;
  test = db.collection('test');
  var data = <Map<String, dynamic>>[];
  for (num i = 0; i < 1000; i++) {
    data.add({'value': i});
  }
  await test.drop();
  print('Sequentially inserting 1000 records with aknowledgment');
  for (var elem in data) {
    await test.insertOne(elem, writeConcern: WriteConcern.acknowledged);
  }

  print(stopwatch.elapsed);
  print('Inserting array of 1000 records with aknowledgment');

  await test.insertMany(data, writeConcern: WriteConcern.acknowledged);
  print(stopwatch.elapsed);
  print('Inserting array of 500 records with aknowledgment');
  await test.insertMany(data.sublist(500),
      writeConcern: WriteConcern.acknowledged);
  print(stopwatch.elapsed);

  await client.close();
}
