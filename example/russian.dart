import 'package:mongo_dart/mongo_dart.dart';

main(){
  Db db = new Db("mongodb://127.0.0.1/mongo_dart-test");
  DbCollection collection;
  print("Connecting to ${db.serverConfig.host}:${db.serverConfig.port}");
  db.open().then((c){
    collection = db.collection('test-utf8');
    collection.remove();
    collection.insert({
      'Имя': 'Вадим',
      'Фамилия':'Цушко',
      'Профессия': 'Брадобрей',
      'Шаблон': new BsonRegexp('^.adim\$')
    });
    return collection.findOne();
  }).then((v){
    print("Utf8 encoding demonstration. I18 strings may be used not only as values but also as keys");
    print(v);
    return collection.findOne(where.eq('Имя', 'Вадим'));
  }).then((v){
    print("Filtered by query().eq(): $v");
    return collection.findOne(where.match('Имя', '^..ДИМ\$',caseInsensitive:true));
  }).then((v){
    print("Filtered by query().match(): $v");
    db.close();
  });
}