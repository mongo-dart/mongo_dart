class DbCollection{
  Db db;
  String collectionName;
  DbCollection(this.db, this.collectionName){}  
  String fullName() => "${db.databaseName}.$collectionName";
  save(Map document){
    if (document.containsKey("_id")){
      update({"_id": document["_id"]}, document);
    } 
    else{
      insert(document);
    }
  }
  insertAll(List<Map> documents){
    MongoInsertMessage insertMessage = new MongoInsertMessage(fullName(),documents);
    return db.executeDbCommand(insertMessage);   
  }
  update(Map selector, Map document){
    MongoUpdateMessage message = new MongoUpdateMessage(fullName(),selector, document, 0);
    return db.executeMessage(message);   
  }
  
  insert(Map document){
    return insertAll([document]);
  } 
  Cursor find([Map selector = const {}, Map fields = null, Map orderBy, int skip = 0,int limit = 0, bool hint = false, bool explain = false] ){
    return new Cursor(db, this, selector: selector, fields: fields, skip: skip, limit: limit, sort: orderBy);//, [selector, skip, limit,sort, hint, explain]);
  }
  findOne([Map selector = const {}, Map fields = null, Map orderBy, int skip = 0,int limit = 0, bool hint = false, bool explain = false] ){
    Cursor cursor = find(selector,fields,orderBy,skip,limit,hint,explain);
    Future result = cursor.nextObject();
    cursor.close();
    return result;
  }
  Future drop() => db.dropCollection(collectionName);
  remove([Map selector = const {}]) => db.removeFromCollection(collectionName, selector);
  Future count([Map selector = const {}]){
    Completer completer = new Completer();
    db.executeDbCommand(DbCommand.createCountCommand(db,collectionName,selector)).then((reply){       
      //print("reply = ${reply}");
      completer.complete(reply["n"]);      
    });
    return completer.future;
  }
}