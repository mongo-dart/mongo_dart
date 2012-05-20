Objectory get objectory() => new ObjectorySingleton._singleton();
abstract class ObjectorySingleton extends ObjectoryBaseImpl{
  static Objectory _objectory;
  ObjectorySingleton._internal();
  factory ObjectorySingleton._singleton(){
    if (_objectory === null){
      _objectory = new ObjectoryWebSocketImpl._internal();
    }
    return _objectory;
  }
}
class ObjectoryWebSocketImpl extends ObjectorySingleton{
  ObjectoryWebSocketImpl._internal():super._internal();
  WebSocket webSocket;
  String socketId; 
  Completer onMessageCompleter;
  Future<bool> open([String database, String url]){
    Completer completer = new Completer();    
    if (database !== null){
      throw "Database paramater is not supported in WebSocket objectory implementation";
    }
    if (url === null){
      throw "Url paramater is mandatory in WebSocket objectory implementation";
    }
    webSocket = new WebSocket(url);
    onMessageCompleter = new Completer();
    webSocket.onopen = (){
      webSocket.send("Objectory opened");    
      completer.complete(true);          
      webSocket.onmessage = processMessage;
    };        
    return completer.future;    
  }
  Future get onMessageFuture() => onMessageCompleter.future;
  void processMessage(message){
    var data = message.data;
    print("in process message $data");
    if (data is String){
      socketId = data;
      print("socketId  $socketId");
    }
    else{    
      Binary buffer = new Binary.from(data);    
      BsonMap command = new BsonMap(null);
      command.unpackValue(buffer);
      print(command.data);    
    }
    onMessageCompleter.complete(true);
  }  
  Binary sendMessage(String command, Map obj, [String collecion]){
    Map map = {};
    map["command"] = command;
    map["object"] = obj;
    map["socketId"] = socketId;
    BsonMap bmap = new BsonMap(map);
    Binary message = new Binary(bmap.byteLength());
    bmap.packValue(message);
    webSocket.send(message.byteList);        
  }
  void save(RootPersistentObject persistentObject){    
    String command = 'update';
    if (persistentObject.id === null){
       command = 'insert';
       persistentObject.id = new ObjectId();
       persistentObject.map["_id"] = persistentObject.id;
    }
    sendMessage(command,persistentObject.map,persistentObject.type);
  }
  void remove(RootPersistentObject persistentObject){

    if (persistentObject.id === null){
      return;
    }
    sendMessage("remove",{"_id":persistentObject.id},persistentObject.type);
  }
/*  Future<List<PersistentObject>> find(String className,[Map selector]){
    Completer completer = new Completer();
    List<PersistentObject> result = new List<PersistentObject>();
    db.collection(className)
      .find(selector)
      .each((map){
        RootPersistentObject obj = objectory.map2Object(className,map);
        result.add(obj);
      }).then((_) => completer.complete(result));
    return completer.future;  
  }
  Future<PersistentObject> findOne(String className,[Map selector]){
    Completer completer = new Completer();    
    db.collection(className)
      .findOne(selector)
      .then((map){              
        PersistentObject obj = objectory.map2Object(className,map);
        completer.complete(obj);
      });
    return completer.future;  
  }
  
  Future<bool> dropDb(){
    db.drop();
  }
*/  
}
