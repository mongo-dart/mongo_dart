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
 Future update(Map selector, Map document, {bool safeMode: false}){
    MongoUpdateMessage message = new MongoUpdateMessage(fullName(),selector, document, 0);
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
 *
 * [selector] map representing query to locate objects. If omitted, query matches all documents in colleciton.
 * Here's a more selective example:
 *     find({'last_name': 'Smith'})
 * Here our selector will match every document where the last_name attribute is 'Smith.'
 *
 */
  Cursor find([Map selector = const {}, Map fields = null, Map orderBy, int skip = 0,int limit = 0, bool hint = false, bool explain = false] ) {
    return new Cursor(db, this, selector, fields, skip, limit, orderBy);//, [selector, skip, limit,sort, hint, explain]);
  }
  Future<Map> findOne([Map selector = const {}, Map fields = null, Map orderBy, int skip = 0,int limit = 0, bool hint = false, bool explain = false] ){
    Cursor cursor = find(selector, fields, orderBy, skip, limit, hint, explain);
    Future<Map> result = cursor.nextObject();
    cursor.close();
    return result;
  }
  Future drop() => db.dropCollection(collectionName);
  Future remove({Map selector: const {}}) => db.removeFromCollection(collectionName, selector);
  Future count({Map selector: const {}}){
    Completer completer = new Completer();
    db.executeDbCommand(DbCommand.createCountCommand(db,collectionName,selector)).then((reply){
      //print("reply = ${reply}");
      completer.complete(reply["n"]);
    });
    return completer.future;
  }
  Future insert(Map document, {bool safeMode: false}) => insertAll([document], safeMode: safeMode);
}