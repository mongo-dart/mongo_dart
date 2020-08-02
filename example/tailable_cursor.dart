import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async';

//////// I guess tailable cursor does not work in that example
/// NJ: it works for me provide the collection is not empty...
void main() async {
  var db = Db('mongodb://127.0.0.1/test');

  await db.open();
  var i = 0;
  await db.collection('log').insert({'index': i});
  Timer.periodic(Duration(seconds: 10), (Timer t) async {
    i++;
    print('Insert $i');
    await db.collection('log').insert({'index': i});
    if (i == 10) {
      print('Stop inserting');
      t.cancel();
    }
  });
  var oplog = DbCollection(db, 'log');
  var cursor = oplog.createCursor()
    ..tailable = true
    ..timeout = false
    ..awaitData = false;
  while (true) {
    var doc = await cursor.nextObject();
    if (doc == null) {
      print('.');
      await Future.delayed(Duration(seconds: 1), () => null);
    } else {
      print('Fetched: $doc');
    }
  }
}
