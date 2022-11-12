import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/mongo_client.dart';

void main() async {
  var client = MongoClient('mongodb://127.0.0.1/mongo_dart-test');
  await client.connect();
  var db = client.db();
  var collection = db.collection('test-utf8');
  await collection.remove({});
  await collection.insert({
    'Имя': 'Вадим',
    'Фамилия': 'Цушко',
    'Профессия': 'Брадобрей',
    'Шаблон': BsonRegexp('^.adim\$')
  });
  var v = await collection.findOne();
  print(
      'Utf8 encoding demonstration. I18 strings may be used not only as values but also as keys');
  print(v);
  v = await collection.findOne(where.eq('Имя', 'Вадим'));
  print('Filtered by query().eq(): $v');
  v = await collection
      .findOne(where.match('Имя', '^..ДИМ\$', caseInsensitive: true));
  print('Filtered by query().match(): $v');
  await client.close();
}
