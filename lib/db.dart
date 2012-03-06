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
    connection.execute(message);
  }    
  open(){
    connection.connect();
  }
}