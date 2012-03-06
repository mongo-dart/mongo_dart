class MCollection{
  Db db;
  String collectionName;
  MCollection(this.db, this.collectionName){}  
  String fullName() => "${db.databaseName}.$collectionName";
  save(List<Map> documents){
    MongoInsertMessage insertMessage = new MongoInsertMessage(fullName(),documents);
    db.executeMessage(insertMessage);
  } 
}