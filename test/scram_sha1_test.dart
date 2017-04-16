import 'package:test/test.dart';
import 'package:mongo_dart/mongo_dart.dart';

main() {
  test("Should be able to connect and authenticate", () async {
    var db = new Db('mongodb://test:test@ds031477.mongolab.com:31477/dart');

    await db.open();

    await db.close();
  });
}
