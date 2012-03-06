#import("../lib/mongo.dart");
testDatabaseName(){
  Db db = new Db('db');
  String dbName;
  dbName = 'db';
  db.validateDatabaseName(dbName);
  dbName = 'db';
  db.validateDatabaseName(dbName);  
}
main(){
  testDatabaseName();
}