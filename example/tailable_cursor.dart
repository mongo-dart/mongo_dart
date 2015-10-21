import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async';

//////// I guess tailable cursor does not work in that example
main() async {
  var db = new Db("mongodb://127.0.0.1/local");

  await db.open();
    var oplog = new DbCollection(db, "log");
    Cursor cursor = oplog.createCursor()
        ..tailable  = true
        ..timeout   = false
        ..awaitData = false;
   while (true) {
      var doc = await cursor.nextObject();
      if (doc == null) {
        await new Future.delayed(new Duration(seconds: 1), () => null);
      } else {
        print(doc);
      }
   }

}