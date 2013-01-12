import 'package:mongo_dart/mongo_dart.dart';
main(){
  Db db = new Db("mongodb://127.0.0.1/mongo_dart-blog");
  print("Connecting to ${db.serverConfig.host}:${db.serverConfig.port}");
  DbCollection collection;
  DbCollection usersCollection;
  DbCollection articlesCollection;
  Map<String,Map> authors = new Map<String,Map>();
  Map<String,Map> users = new Map<String,Map>();
  db.open().then((o){
    print(">> Dropping mongo_dart-blog db");
    db.drop();
    print("===================================================================================");
    print(">> Adding Authors");
    collection = db.collection('authors');
    collection.insertAll(
      [{'name':'William Shakespeare', 'email':'william@shakespeare.com', 'age':587},
      {'name':'Jorge Luis Borges', 'email':'jorge@borges.com', 'age':123}]
    );
    return collection.find().each((v){authors[v["name"]] = v;});
  }).then((v){
    print("===================================================================================");
    print(">> Authors ordered by age ascending");
    db.ensureIndex('authors', key: 'age');
    return collection.find(where.sortBy('age')).each(
      (auth)=>print("[${auth['name']}]:[${auth['email']}]:[${auth['age']}]"));
  }).then((v){
    print("===================================================================================");
    print(">> Adding Users");
    usersCollection = db.collection("users");
    usersCollection.insertAll([{'login':'jdoe', 'name':'John Doe', 'email':'john@doe.com'},
       {'login':'lsmith', 'name':'Lucy Smith', 'email':'lucy@smith.com'}]);
    db.ensureIndex('users', keys: {'login': -1});
    return usersCollection.find().each((user)=>users[user["login"]] = user);
  }).then((v){
    print("===================================================================================");
    print(">> Users ordered by login descending");
    return usersCollection.find(where.sortBy('login', descending: true)).each(
      (user)=>print("[${user['login']}]:[${user['name']}]:[${user['email']}]"));
  }).then((v){
    print("===================================================================================");
    print(">> Adding articles");
    articlesCollection = db.collection("articles");
    articlesCollection.insertAll([
                                  { 'title':'Caminando por Buenos Aires',
                                    'body':'Las callecitas de Buenos Aires tienen ese no se que...',
                                    'author_id':authors['Jorge Luis Borges']["_id"]},
                                  { 'title':'I must have seen thy face before',
                                    'body':'Thine eyes call me in a new way',
                                    'author_id':authors['William Shakespeare']["_id"],
                                    'comments':[{'user_id':users['jdoe']["_id"], 'body':"great article!"}]
                                  }
                                ]);
    print("===================================================================================");
    print(">> Articles ordered by title ascending");
    return articlesCollection.find(where.sortBy('title')).each((article){
      print("[${article['title']}]:[${article['body']}]:[author_id: ${article['author_id']}]");
    });
  }).then((v){
    return db.collectionsInfoCursor().each((col) => col);
  }).then((dummy){
    db.close();
  });
}