part of mongo_dart;
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
  static DbCommand createDropCollectionCommand(Db db, String collectionName) {
    return new DbCommand(db,SYSTEM_COMMAND_COLLECTION, MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT, 0, -1, {'drop':collectionName}, null);
  }
  static DbCommand createDropDatabaseCommand(Db db) {
    return new DbCommand(db, SYSTEM_COMMAND_COLLECTION, MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT, 0, -1, {'dropDatabase':1}, null);
  }
  static DbCommand createQueryDBCommand(Db db, Map command) {
    return new DbCommand(db, SYSTEM_COMMAND_COLLECTION, MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT, 0, 1, command, null);
  }
  static DbCommand createDBSlaveOKCommand(Db db, Map command) {
    return new DbCommand(db, SYSTEM_COMMAND_COLLECTION, MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT | MongoQueryMessage.OPTS_SLAVE, 0, -1, command, null);
  }

  static DbCommand createPingCommand(Db db) {
    return createQueryDBCommand(db, {'ping':1});
  }
  static DbCommand createGetNonceCommand(Db db) {
    return createQueryDBCommand(db, {'getnonce':1});
  }

  static DbCommand createGetLastErrorCommand(Db db, {bool j: false, int w: 0}) {
    return createQueryDBCommand(db, {"getlasterror":1, "j": j, "w": w});
  }
  static DbCommand createCountCommand(Db db, String collectionName, [Map selector = const {}]) {
    var finalQuery = new Map();
    finalQuery["query"] = selector;
    finalQuery["count"] = collectionName;
    return new DbCommand(db, SYSTEM_COMMAND_COLLECTION, MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT, 0, -1, finalQuery, null);
  }
  static DbCommand createAuthenticationCommand(Db db, String userName, String password, String nonce) {
    var md5 = new MD5();
    md5.add("${userName}:mongo:${password}".codeUnits);
    var hashed_password = new BsonBinary.from(md5.close()).hexString;
    md5 = new MD5();
    md5.add("${nonce}${userName}${hashed_password}".codeUnits);
    var key = new BsonBinary.from(md5.close()).hexString;
    var selector = {'authenticate':1, 'user':userName, 'nonce':nonce, 'key':key};
    return new DbCommand(db, SYSTEM_COMMAND_COLLECTION, MongoQueryMessage.OPTS_NONE, 0, -1, selector, null);
  }
  
  static DbCommand createDistinctCommand(Db db, String collectionName, String field, [Map selector = const {}]) {
    return new DbCommand(db, SYSTEM_COMMAND_COLLECTION, MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT, 0, -1, 
      {'distinct': collectionName, 'key': field, 'query': selector }, null);
  }
  
  static DbCommand createAggregateCommand(Db db, String collectionName, List pipeline) {
    return new DbCommand(db, SYSTEM_COMMAND_COLLECTION, MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT, 0, -1, 
      {'aggregate': collectionName, 'pipeline': pipeline }, null);
  }
}