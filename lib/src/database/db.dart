part of mongo_dart;

class WriteConcern { 
  static const ERRORS_IGNORED = const WriteConcern._(-1);   
  static const UNACKNOWLEDGED = const WriteConcern._(0); 
  static const ACKNOWLEDGED = const WriteConcern._(1); 
  static const JOURNALED = const WriteConcern._(2);  
  const WriteConcern._(this.value); 
  final int value; 
} 


class Db{
  String databaseName;
  ServerConfig serverConfig;
  Connection connection;
  WriteConcern _writeConcern;
  _validateDatabaseName(String dbName) {
    if(dbName.length == 0) throw "database name cannot be the empty string";
    var invalidChars = [" ", ".", "\$", "/", "\\"];
    for(var i = 0; i < invalidChars.length; i++) {
      if(dbName.indexOf(invalidChars[i]) != -1) throw new Exception("database names cannot contain the character '${invalidChars[i]}'");
    }
  }

/**
* Db constructor expects [valid mongodb URI] (http://www.mongodb.org/display/DOCS/Connections).
* For example next code points to local mongodb server on default mongodb port, database *testdb*
*     var db = new Db('mongodb://127.0.0.1/testdb');
* And that code direct to MongoLab server on 37637 port, database *testdb*, username *dart*, password *test*
*     var db = new Db('mongodb://dart:test@ds037637-a.mongolab.com:37637/objectory_blog');
*/
  Db(String uriString){
    _configureConsoleLogger();
    var uri = Uri.parse(uriString);
    if (uri.scheme != 'mongodb') {
      throw 'Invalid scheme in uri: $uriString ${uri.scheme}';
    }
    serverConfig = new ServerConfig();
    serverConfig.host = uri.host;
    serverConfig.port = uri.port;
    if (serverConfig.port == null || serverConfig.port == 0){
      serverConfig.port = 27017;
    }
    if (uri.userInfo != '') {
      var userInfo = uri.userInfo.split(':');
      if (userInfo.length != 2) {
        throw 'Неверный формат поля userInfo: $uri.userInfo';
      }
      serverConfig.userName = userInfo[0];
      serverConfig.password = userInfo[1];
    }
    if (uri.path != '') {
      databaseName = uri.path.replaceAll('/','');
    }
    connection = new Connection(serverConfig);
  }
  DbCollection collection(String collectionName){
      return new DbCollection(this,collectionName);
  }
  Future queryMessage(MongoMessage queryMessage){
    return connection.query(queryMessage);
  }
  executeMessage(MongoMessage message){
    connection.execute(message);
  }
  Future open({WriteConcern writeConcern: WriteConcern.ACKNOWLEDGED}){
    
    _writeConcern = writeConcern;
    if (connection.connected){
      connection.close();
      connection = new Connection(serverConfig);
    }
    
    return connection.connect().then((v) {
      if (serverConfig.userName == null) {
        return v;
      }
      else {
        return authenticate(serverConfig.userName,serverConfig.password).then((v) {
          return v;
        });
      }
    });    
  }
  Future executeDbCommand(MongoMessage message){
      Completer<Map> result = new Completer();
      connection.query(message).then((replyMessage){
        String errMsg;
        if (replyMessage.documents.length == 0) {
          errMsg = "Error executing Db command, Document length 0 $replyMessage";
          print("Error: $errMsg");
          var m = new Map();
          m["errmsg"]=errMsg;
          result.completeError(m);
        } else  if (replyMessage.documents[0]['ok'] == 1.0 && replyMessage.documents[0]['err'] == null){
          result.complete(replyMessage.documents[0]);
        } else {
          result.completeError(replyMessage.documents[0]);
        }
      });
    return result.future;
  }
  Future dropCollection(String collectionName){
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
/**
*   Drop current database
*/
  Future drop(){
    return executeDbCommand(DbCommand.createDropDatabaseCommand(this));
  }

  Future removeFromCollection(String collectionName, [Map selector = const {}, WriteConcern writeConcern]){
    executeMessage(new MongoRemoveMessage("$databaseName.$collectionName", selector));
    return _getAcknowledgement(writeConcern: writeConcern); 
  }

  Future<Map> getLastError({bool j: false, int w: 0}){
    return executeDbCommand(DbCommand.createGetLastErrorCommand(this, j: j, w: w));
  }
  Future<Map> getNonce(){
    return executeDbCommand(DbCommand.createGetNonceCommand(this));
  }

  Future<Map> wait(){
    return getLastError();
  }
  void close(){
    connection.close();
  }

  Cursor collectionsInfoCursor([String collectionName]) {
    Map selector = {};
    // If we are limiting the access to a specific collection name
    if(collectionName != null){
      selector["name"] = "${this.databaseName}.$collectionName";
    }
    // Return Cursor
      return new Cursor(this, new DbCollection(this, DbCommand.SYSTEM_NAMESPACE_COLLECTION), selector);
  }

  Future<bool> authenticate(String userName, String password){
    return getNonce().then((msg) {
      var nonce = msg["nonce"];
      var command = DbCommand.createAuthenticationCommand(this,userName,password,nonce);
      serverConfig.password = '***********';
      return executeDbCommand(command);
    }).then( (res) => res["ok"]==1 );
  }
  Future<List> indexInformation([String collectionName]) {
    var selector = {};
    if (collectionName != null) {
      selector['ns'] = '$databaseName.$collectionName';
    }
    return new Cursor(this, new DbCollection(this, DbCommand.SYSTEM_INDEX_COLLECTION), selector).toList();
  }
  String _createIndexName(Map keys) {
    var name = '';
    keys.forEach((key,value) {
      name = '${name}_${key}_$value';
    });
    return name;
  }
  Future createIndex(String collectionName, {String key, Map keys, bool unique, bool sparse, bool background, bool dropDups, String name}) {
    var selector = {};
    selector['ns'] = '$databaseName.$collectionName';
    keys = _setKeys(key, keys);
    selector['key'] = keys;
    for (final order in keys.values) {
      if (order != 1 && order != -1) {
        throw new ArgumentError('Keys may contain only 1 or -1');
      }
    }
    if (unique == true) {
      selector['unique'] = true;
    } else {
      selector['unique'] = false;
    }
    if (sparse == true) {
      selector['sparse'] = true;
    }
    if (background == true) {
      selector['background'] = true;
    }
    if (dropDups == true) {
      selector['dropDups'] = true;
    }
    if (name ==  null) {
      name = _createIndexName(keys);
    }
    selector['name'] = name;
    MongoInsertMessage insertMessage = new MongoInsertMessage('$databaseName.${DbCommand.SYSTEM_INDEX_COLLECTION}',[selector]);
    executeMessage(insertMessage);
    return getLastError();
  }

  Map _setKeys(String key, Map keys) {
    if (key != null && keys != null) {
      throw new ArgumentError('Only one parameter must be set: key or keys');
    }
    if (key != null) {
      keys = new Map();
      keys['$key'] = 1;
    }
    if (keys == null) {
      throw new ArgumentError('key or keys parameter must be set');
    }
    return keys;
  }
  Future ensureIndex(String collectionName, {String key, Map keys, bool unique, bool sparse, bool background, bool dropDups, String name}) {
    keys = _setKeys(key, keys);
    var completer = new Completer();
    indexInformation(collectionName).then((indexInfos) {
      if (name == null) {
        name = _createIndexName(keys);
      }
      if (indexInfos.any((info) => info['name'] == name)) {
        completer.complete({'ok': 1.0, 'result': 'index preexists'});
      } else {
        createIndex(collectionName,keys: keys, unique: unique, sparse: sparse, background: background, dropDups: dropDups, name: name)
          .then((res)=>completer.complete(res));
      }
    });
    return completer.future;
  }
  
  Future _getAcknowledgement({WriteConcern writeConcern}) {
    if (writeConcern == null) {
      writeConcern = _writeConcern;
    }
    if (writeConcern == WriteConcern.ERRORS_IGNORED) {
      return new Future.value({'ok': 1.0});            
    }
    else
    {
      return getLastError(j: writeConcern == WriteConcern.JOURNALED, w: min(1, writeConcern.value));
    }   
  }
}




