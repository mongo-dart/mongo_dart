class MCollection{
  Db db;
  String collectionName;
  MCollection(this.db, this.collectionName){}  
  String fullName() => "${db.databaseName}.$collectionName";
  saveAll(List<Map> documents){
    insertAll(documents);
  } 
  save(Map document){
    return saveAll([document]);  
  }
  insertAll(List<Map> documents){
    MongoInsertMessage insertMessage = new MongoInsertMessage(fullName(),documents);
    return db.executeDbCommand(insertMessage);   
  }
  insert(Map document){
    return insertAll([document]);
  } 
  Cursor find([Map selector = const {}, Map fields = null, Map sort, int skip = 0,int limit = 30, bool hint = false, bool explain = false] ){
    return new Cursor(db, this, selector);//, [selector, skip, limit,sort, hint, explain]);
  }
  findOne([Map selector = const {}, Map fields = null, Map sort, int skip = 0,int limit = 30, bool hint = false, bool explain = false] ){
    return find(selector,fields,sort,skip,limit,hint,explain).nextObject();
  }
  drop() => db.dropCollection(collectionName);
  remove([Map selector = const {}]) => db.removeFromCollection(collectionName, selector);
}