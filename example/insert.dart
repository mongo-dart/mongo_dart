import 'package:mongo_dart/mongo_dart.dart';

main() async {
  Db db = new Db("mongodb://127.0.0.1/test_insert"); //
  //Db db = new Db("mongodb://test:test@ds061298.mongolab.com:61298/test_insert");
  Stopwatch stopwatch = new Stopwatch()..start();
  DbCollection test;
  await db.open();
  test = db.collection('test');
  var data = [];
  for (num i = 0; i < 1000; i++) {
    data.add({'value': i});
  }
  await test.drop();
  print('Sequentially inserting 1000 records with aknowledgment');
  for (var elem in data) {
    await test.insert(elem, writeConcern: WriteConcern.ACKNOWLEDGED);
  }
  ;
  print(stopwatch.elapsed);
  print('Inserting array of 1000 records with aknowledgment');
  var res = await test.insertAll(data, writeConcern: WriteConcern.ACKNOWLEDGED);
  print(res);
  print(stopwatch.elapsed);
  print('Inserting array of 500 records with aknowledgment');
  res = await test.insertAll(data.sublist(500),
      writeConcern: WriteConcern.ACKNOWLEDGED);
  print(res);
  print(stopwatch.elapsed);

  await db.close();
}
