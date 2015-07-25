import 'package:mongo_dart/mongo_dart.dart';

main() async {
  var db = new Db("mongodb://127.0.0.1/local");

  await db.open();
  var oplog = new DbCollection(db, "oplog.rs");
  var cursor = oplog.find()
    ..tailable = true
    ..timeout = false
    ..awaitData = true;

  var subscription = cursor.stream.listen((value) => print(value),
      onError: (err) => print("error: $err"), onDone: () => print("done"));
}
