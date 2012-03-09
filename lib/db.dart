class Db{
  String databaseName;
  ServerConfig serverConfig;
  Connection connection;
  validateDatabaseName(String databaseName) {
    if(databaseName.length === 0) throw "database name cannot be the empty string";  
    var invalidChars = [" ", ".", "\$", "/", "\\"];
    for(var i = 0; i < invalidChars.length; i++) {
      if(databaseName.indexOf(invalidChars[i]) != -1) throw new Exception("database names cannot contain the character '" + invalidChars[i] + "'");
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
  Future<Map> executeQueryMessage(MongoQueryMessage queryMessage){
    return connection.query(queryMessage);
  }  
  executeMessage(MongoMessage message){
    return connection.execute(message);
  }    
  open(){
    connection.connect();
  }
  Future<bool> executeDbCommand(MongoMessage message){
      Completer<bool> result = new Completer();
      connection.query(message).then((replyMessage){
        if (replyMessage.documents[0]["ok"] == 1.0){
          print(replyMessage.documents[0]);
          result.complete(true);
        } else {
          String errMsg = "Error executing Db command";
          if (replyMessage.documents[0].containsKey("errmsg")){
            errMsg = replyMessage.documents[0]["errmsg"];
          }
          print(errMsg);
          result.complete(false);
        }         
      });
    return result.future;        
  }  
  Future<bool> dropCollection(String collectionName){    
    return executeDbCommand(DbCommand.createDropCollectionCommand(this,collectionName));
  }  
  Future<bool> getLastError(){    
    return executeDbCommand(DbCommand.createGetLastErrorCommand(this));
  }  

}