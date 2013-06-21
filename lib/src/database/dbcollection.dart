part of mongo_dart;
class DbCollection{
  Db db;
  String collectionName;
  DbCollection(this.db, this.collectionName){}
  String fullName() => "${db.databaseName}.$collectionName";
  void save(Map document, {WriteConcern writeConcern}){
    var id;
    bool createId = false;
    if (document.containsKey("_id")){
      id = document["_id"];
      if (id == null){
        createId = true;
      }
    }
    if (id != null){
      update({"_id": id}, document, writeConcern: writeConcern);
    }
    else{
      if (createId) {
        document["_id"] = new ObjectId();
      }
      insert(document, writeConcern: writeConcern);
    }
  }
 Future insertAll(List<Map> documents, {WriteConcern writeConcern}){
    MongoInsertMessage insertMessage = new MongoInsertMessage(fullName(),documents);
    db.executeMessage(insertMessage);
    return db._getAcknowledgement(writeConcern: writeConcern);
  }
  Future update(selector, document, {bool upsert: false, WriteConcern writeConcern}){
    int flags = 0;
    if (upsert) {
      flags |= 0x1;
    }

    MongoUpdateMessage message = new MongoUpdateMessage(fullName(), 
        _selectorBuilder2Map(selector), document, flags);
    db.executeMessage(message);
    return db._getAcknowledgement(writeConcern: writeConcern);
  }

 /**
  * Creates a cursor for a query that can be used to iterate over results from MongoDB
  * ##[selector]
  * parameter represents query to locate objects. If omitted as in `find()` then query matches all documents in colleciton.
  * Here's a more selective example:
  *     find({'last_name': 'Smith'})
  * Here our selector will match every document where the last_name attribute is 'Smith.'
  *
  */
  Cursor find([selector]) {
    return new Cursor(db, this, selector);
  }

  Future<Map> findOne([selector]){
    Cursor cursor = find(selector);
    Future<Map> result = cursor.nextObject();
    cursor.close();
    return result;
  }
  Future drop() => db.dropCollection(collectionName);
  Future remove([selector, WriteConcern writeConcern]) => db.removeFromCollection(collectionName, _selectorBuilder2Map(selector), writeConcern);
  Future<int> count([selector]){
    Completer completer = new Completer();
    db.executeDbCommand(DbCommand.createCountCommand(db,collectionName,_selectorBuilder2Map(selector))).then((reply){
      completer.complete(reply["n"].toInt());
    });
    return completer.future;
  }
  
  Future distinct(String field, [selector]){
    Completer completer = new Completer();
    db.executeDbCommand(DbCommand.createDistinctCommand(db,collectionName,field,_selectorBuilder2Map(selector))).then((reply){
      completer.complete(reply);
    });
    return completer.future;
  }
  
  Future aggregate(List pipeline){
    Completer completer = new Completer();
    var cmd = DbCommand.createAggregateCommand(db,collectionName,pipeline);
    db.executeDbCommand(cmd)
      .then((reply){
      completer.complete(reply);
    });
    
    return completer.future;
  }
  
  Future insert(Map document, {WriteConcern writeConcern}) => insertAll([document], writeConcern: writeConcern);

  Map _selectorBuilder2Map(selector) {
    if (selector == null) {
      return {};
    }
    if (selector is SelectorBuilder) {
      return selector.map['\$query'];
    }
    return selector;
  }
}