class DbCommand extends MongoQueryMessage{
  // Constants
  static final SYSTEM_NAMESPACE_COLLECTION = "system.namespaces";
  static final SYSTEM_INDEX_COLLECTION = "system.indexes";
  static final SYSTEM_PROFILE_COLLECTION = "system.profile";
  static final SYSTEM_USER_COLLECTION = "system.users";
  static final SYSTEM_COMMAND_COLLECTION = "\$cmd";

  Db db;  
  DbCommand(this.db, collectionName, flags, numberToSkip, numberToReturn, query, fields)
    :super(collectionName,flags, numberToSkip, numberToReturn, query, fields){      
    _collectionFullName = new BsonCString("${db.databaseName}.$collectionName");      
  }
  static createDropCollectionCommand(Db db, String collectionName) {
    return new DbCommand(db, SYSTEM_COMMAND_COLLECTION, MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT, 0, -1, {'drop':collectionName}, null);
  }
  static createPingCommand(Db db) {
    return new DbCommand(db, SYSTEM_COMMAND_COLLECTION, MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT, 0, 1, {'ping':1}, null);
  }  
  static createGetLastErrorCommand(Db db) {
    return new DbCommand(db, SYSTEM_COMMAND_COLLECTION, MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT, 0, 1, {"getlasterror":1}, null);
  }  

}