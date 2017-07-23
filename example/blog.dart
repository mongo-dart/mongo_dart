import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io' show Platform;

String host = Platform.environment['MONGO_DART_DRIVER_HOST'] ?? '127.0.0.1';
String port = Platform.environment['MONGO_DART_DRIVER_PORT'] ?? '27017';

main() async {
  Db db = new Db("mongodb://$host:$port/mongo_dart-blog");
  Map<String, Map> authors = new Map<String, Map>();
  Map<String, Map> users = new Map<String, Map>();
  await db.open();
  await db.drop();
  print("====================================================================");
  print(">> Adding Authors");
  var collection = db.collection('authors');
  await collection.insertAll([
    {
      'name': 'William Shakespeare',
      'email': 'william@shakespeare.com',
      'age': 587
    },
    {'name': 'Jorge Luis Borges', 'email': 'jorge@borges.com', 'age': 123}
  ]);
  await db.ensureIndex('authors',
      name: 'meta', keys: {'_id': 1, 'name': 1, 'age': 1});
  await collection.find().forEach((v) {
    print(v);
    authors[v["name"]] = v;
  });
  print("====================================================================");
  print(">> Authors ordered by age ascending");
  await collection.find(where.sortBy('age')).forEach(
      (auth) => print("[${auth['name']}]:[${auth['email']}]:[${auth['age']}]"));
  print("====================================================================");
  print(">> Adding Users");
  var usersCollection = db.collection("users");
  await usersCollection.insertAll([
    {'login': 'jdoe', 'name': 'John Doe', 'email': 'john@doe.com'},
    {'login': 'lsmith', 'name': 'Lucy Smith', 'email': 'lucy@smith.com'}
  ]);
  await db.ensureIndex('users', keys: {'login': -1});
  await usersCollection.find().forEach((user) {
    users[user["login"]] = user;
    print(user);
  });
  print("====================================================================");
  print(">> Users ordered by login descending");
  await usersCollection.find(where.sortBy('login', descending: true)).forEach(
      (user) =>
          print("[${user['login']}]:[${user['name']}]:[${user['email']}]"));
  print("====================================================================");
  print(">> Adding articles");
  var articlesCollection = db.collection("articles");
  await articlesCollection.insertAll([
    {
      'title': 'Caminando por Buenos Aires',
      'body': 'Las callecitas de Buenos Aires tienen ese no se que...',
      'author_id': authors['Jorge Luis Borges']["_id"]
    },
    {
      'title': 'I must have seen thy face before',
      'body': 'Thine eyes call me in a new way',
      'author_id': authors['William Shakespeare']["_id"],
      'comments': [
        {'user_id': users['jdoe']["_id"], 'body': "great article!"}
      ]
    }
  ]);
  print("====================================================================");
  print(">> Articles ordered by title ascending");
  await articlesCollection.find(where.sortBy('title')).forEach((article) {
    print(
        "[${article['title']}]:[${article['body']}]:[${article['author_id'].toHexString()}]");
  });
  await db.close();
}
