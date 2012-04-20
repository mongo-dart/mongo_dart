#import("../lib/mongo.dart");
#import("dart:builtin");

main(){
  Db db = new Db("mongo-dart-blog");
  print("Connecting to ${db.serverConfig.host}:${db.serverConfig.port}");
  DbCollection collection;
  DbCollection usersCollection;
  DbCollection articlesCollection;
  Map<String,Map> authors = new Map<String,Map>();
  Map<String,Map> users = new Map<String,Map>();  
  db.open().chain((o){
    print(">> Dropping mongo-dart-blog db");
    db.drop();
    print("===================================================================================");
    print(">> Adding Authors");
    collection = db.collection("authors");
    collection.insertAll(
      [{'name':'William Shakespeare', 'email':'william@shakespeare.com', 'age':587},
      {'name':'Jorge Luis Borges', 'email':'jorge@borges.com', 'age':123}]
    );
    return collection.find().each((v){authors[v["name"]] = v;});
  }).chain((v){  
    print("===================================================================================");
    print(">> Authors ordered by age ascending");
    return collection.find(orderBy:{'age':1}).each(
      (auth)=>print("[${auth['name']}]:[${auth['email']}]:[${auth['age']}]"));
  }).chain((v){
    print("===================================================================================");
    print(">> Adding Users");
    usersCollection = db.collection("users");
    usersCollection.insertAll([{'login':'jdoe', 'name':'John Doe', 'email':'john@doe.com'}, 
       {'login':'lsmith', 'name':'Lucy Smith', 'email':'lucy@smith.com'}]);
    return usersCollection.find().each((user)=>users[user["login"]] = user);      
  }).chain((v){
    print("===================================================================================");
    print(">> Users ordered by login ascending");
    return usersCollection.find(orderBy:{"login":1}).each(
      (user)=>print("[${user['login']}]:[${user['name']}]:[${user['email']}]"));      
  }).chain((v){
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
    return articlesCollection.find(orderBy:{"title":1}).each((article){
      print("[${article['title']}]:[${article['body']}]:[author_id: ${article['author_id']}]");
    });      
  }).then((dummy){
    db.close();
  });      
}