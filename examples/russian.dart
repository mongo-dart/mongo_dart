#import("../lib/mongo.dart");
#import("../lib/bson/bson.dart");
#import("dart:builtin");

main(){
  Db db = new Db("mongo-dart-test");
  DbCollection collection;
  print("Connecting to ${db.serverConfig.host}:${db.serverConfig.port}");
  db.open().chain((c){  
    collection = db.collection('test-utf8');
    collection.remove();  
    collection.insert({
      'Имя': 'Вадим', 
      'Фамилия':'Цушко',
      'Профессия': 'Брадобрей',
      'Шаблон': new BsonRegexp('^.adim\$')
    });    
    return collection.findOne();
  }).chain((v){
    print("Utf8 encoding demonstration. I18 strings may be used not only as values but also as keys");
    print(v);    
    return collection.findOne(query().eq('Имя', 'Вадим'));
  }).chain((v){
    print("Filtered by query().eq(): $v");
    return collection.findOne(query().match('Имя', '^..ДИМ\$',caseInsensitive:true));    
  }).then((v){    
    print("Filtered by query().match(): $v");
    db.close();  
  });  
}  