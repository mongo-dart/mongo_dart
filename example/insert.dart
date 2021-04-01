import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  var db = Db('mongodb://127.0.0.1/test_insert'); //
  var stopwatch = Stopwatch()..start();
  DbCollection test;
  await db.open();
  test = db.collection('test');
  var data = <Map<String, dynamic>>[];
  for (num i = 0; i < 1000; i++) {
    data.add({'value': i});
  }
  await test.drop();
  print('Sequentially inserting 1000 records with aknowledgment');
  for (var elem in data) {
    await test.insertOne(elem, writeConcern: WriteConcern.ACKNOWLEDGED);
  }

  print(stopwatch.elapsed);
  print('Inserting array of 1000 records with aknowledgment');

  await test.insertMany(data, writeConcern: WriteConcern.ACKNOWLEDGED);
  print(stopwatch.elapsed);
  print('Inserting array of 500 records with aknowledgment');
  await test.insertMany(data.sublist(500),
      writeConcern: WriteConcern.ACKNOWLEDGED);
  print(stopwatch.elapsed);

  await db.close();
}
