import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async';

//////// I guess tailable cursor does not work in that example
/// NJ: it works for me provide the collection is not empty...
main() async {
  var db = new Db("mongodb://127.0.0.1/test");

  await db.open();
  var i = 0;
  await db.collection("log").insert({"index": i});
  new Timer.periodic(new Duration(seconds: 10), (Timer t) async {
    i++;
    print("Insert $i");
    await db.collection("log").insert({"index": i});
    if (i == 10) {
      print("Stop inserting");
      t.cancel();
    }
  });
  var oplog = new DbCollection(db, "log");
  Cursor cursor = oplog.createCursor()
    ..tailable = true
    ..timeout = false
    ..awaitData = false;
  while (true) {
    var doc = await cursor.nextObject();
    if (doc == null) {
      print(".");
      await new Future.delayed(new Duration(seconds: 1), () => null);
    } else {
      print("Fetched: $doc");
    }
  }
}
