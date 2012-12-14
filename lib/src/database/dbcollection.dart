part of mongo_dart;
class DbCollection{
  Db db;
  String collectionName;
  DbCollection(this.db, this.collectionName){}
  String fullName() => "${db.databaseName}.$collectionName";
  void save(Map document){
    var id;
    bool createId = false;
    if (document.containsKey("_id")){
      id = document["_id"];
      if (id == null){
        createId = true;
      }
    }
    if (id != null){
      update({"_id": id}, document);
    }
    else{
      if (createId) {
        document["_id"] = new ObjectId();
      }
      insert(document);
    }
  }
 Future insertAll(List<Map> documents, {bool safeMode: false}){
    MongoInsertMessage insertMessage = new MongoInsertMessage(fullName(),documents);
    db.executeMessage(insertMessage);
    if (safeMode) {
      return db.getLastError();
    }
    else
    {
      return new Future.immediate({'ok': 1.0});
    }
  }
 Future update(selector, document, {bool safeMode: false}){
    MongoUpdateMessage message = new MongoUpdateMessage(fullName(),_selectorBuiltder2Map(selector), document, 0);
    db.executeMessage(message);
    if (safeMode) {
      return db.getLastError();
    }
    else
    {
      return new Future.immediate({'ok': 1.0});
    }
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
  Future remove([selector]) => db.removeFromCollection(collectionName, _selectorBuiltder2Map(selector));
  Future count([selector]){
    Completer completer = new Completer();
    db.executeDbCommand(DbCommand.createCountCommand(db,collectionName,_selectorBuiltder2Map(selector))).then((reply){
      //print("reply = ${reply}");
      completer.complete(reply["n"]);
    });
    return completer.future;
  }
  Future insert(Map document, {bool safeMode: false}) => insertAll([document], safeMode: safeMode);

  Map _selectorBuiltder2Map(selector) {
    if (selector == null) {
      return {};
    }
    if (selector is SelectorBuilder) {
      return selector.map;
    }
    return selector;
  }
}