#import("../lib/mongo.dart");
testCollectionCreation(){
  Db db = new Db('db');
  MCollection collection = db.collection('student');
}
main(){

  testCollectionCreation();
}