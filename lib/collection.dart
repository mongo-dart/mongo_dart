class MCollection{
  Db db;
  String collectionName;
  MCollection(this.db, this.collectionName){}  
  String fullName() => "${db.databaseName}.$collectionName";
  saveAll(List<Map> documents){
    MongoInsertMessage insertMessage = new MongoInsertMessage(fullName(),documents);
    return db.executeDbCommand(insertMessage);
  } 
  save(Map document){
    return saveAll([document]);  
  } 
  find([Map selector = const {}, Map fields = null, Map sort, int skip = 0,int limit = 30, bool hint = false, bool explain = false] ){
    return new Cursor(db, this);//, [selector, skip, limit,sort, hint, explain]);
  }
  drop() => db.dropCollection(collectionName);
}