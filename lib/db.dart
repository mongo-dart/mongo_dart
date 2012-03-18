class Db{
  String databaseName;
  ServerConfig serverConfig;
  Connection connection;
  validateDatabaseName(String dbName) {
    if(dbName.length === 0) throw "database name cannot be the empty string";  
    var invalidChars = [" ", ".", "\$", "/", "\\"];
    for(var i = 0; i < invalidChars.length; i++) {
      if(dbName.indexOf(invalidChars[i]) != -1) throw new Exception("database names cannot contain the character '" + invalidChars[i] + "'");
    }
  }    
  Db(this.databaseName, [this.serverConfig]){
     if (serverConfig === null) {
      serverConfig = new ServerConfig();
     }
    connection = new Connection(serverConfig);
  }      
  MCollection collection(String collectionName){
      return new MCollection(this,collectionName);
  }
  Future<MongoReplyMessage> executeQueryMessage(MongoMessage queryMessage){
    return connection.query(queryMessage);
  }  
  executeMessage(MongoMessage message){
    return connection.execute(message);
  }    
  open(){
    connection.connect();
    return this;
  }
  Future<Map> executeDbCommand(MongoMessage message){
      Completer<bool> result = new Completer();
      connection.query(message).then((replyMessage){
        if (replyMessage.documents[0]["ok"] == 1.0){
          result.complete(replyMessage.documents[0]);
        } else {
          String errMsg = "Error executing Db command";
          if (replyMessage.documents[0].containsKey("errmsg")){
            errMsg = replyMessage.documents[0]["errmsg"];
          }
          print("Error: $errMsg");
          result.complete(replyMessage.documents[0]);
        }         
      });
    return result.future;        
  }
  Future<bool> dropCollection(String collectionName){
    Completer completer = new Completer();
    collectionsInfoCursor(collectionName).toList().then((v){
      if (v.length == 1){
        executeDbCommand(DbCommand.createDropCollectionCommand(this,collectionName))
          .then((res)=>completer.complete(res));
        } else{
          completer.complete(true);
        }  
    });    
    return completer.future;    
  }
  removeFromCollection(String collectionName, [Map selector = const {}]){
    connection.execute(new MongoRemoveMessage("$databaseName.$collectionName", selector));    
  }    
  
  Future<Map> getLastError(){    
    return executeDbCommand(DbCommand.createGetLastErrorCommand(this));
  }
  Future<Map> wait(){
    return getLastError();
  }
  close(){
    connection.close();
  }
  
  Cursor collectionsInfoCursor([String collectionName]) {
    Map selector = {};
    // If we are limiting the access to a specific collection name
    if(collectionName !== null){
      selector["name"] = this.databaseName + "." + collectionName;
    }  
    // Return Cursor
      return new Cursor(this, new MCollection(this, DbCommand.SYSTEM_NAMESPACE_COLLECTION), selector);      
  }    
}