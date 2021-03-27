import 'package:mongo_dart/mongo_dart.dart';
import 'package:test/test.dart';
import 'database_test.dart';

void main() {
  late ConnectionPool pool;

  setUp(() {
    pool = ConnectionPool(3, () => Db(DefaultUri));
  });

  tearDown(() => pool.close());

  test('recycles connections', () async {
    var db1 = await pool.connect();
    var db2 = await pool.connect();
    var db3 = await pool.connect();
    expect(await pool.connect(), db1);
    expect(await pool.connect(), db2);
    expect(await pool.connect(), db3);
  });
}
