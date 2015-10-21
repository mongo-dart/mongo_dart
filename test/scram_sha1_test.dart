import 'package:test/test.dart';
import 'package:mongo_dart/mongo_dart.dart';

main() {
  test("Should be able to connect", () async {
    var db = new Db(
//        'mongodb://pacane:password@localhost:27017/db1',
        'mongodb://test:test@ds031477.mongolab.com:31477/dart',
        'test scram sha1');
    var connection = await db.open();
//    bool result = await db.authenticate('username', 'password', connection: connection);
    await db.close();

//    expect(result, isTrue);
  });
}
