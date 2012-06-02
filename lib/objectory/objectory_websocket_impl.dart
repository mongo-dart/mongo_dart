/*Objectory get objectory() => new ObjectorySingleton._singleton();
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
  static final IDLE_STATUS = 0;
  static final GET_CONNECTION_ID = 1;
  static final FIND_ONE = 2;
  static final FIND = 3;
  int messageProcessingStatus = IDLE_STATUS;  
  WebSocket webSocket;
  int socketId;  
  Completer onMessageCompleter;
  ObjectoryWebSocketImpl._internal():super._internal();  
  Future<bool> open([String database, String url]){
    Completer completer = new Completer();    
    if (database !== null){
      throw "Database paramater is not supported in WebSocket objectory implementation";
    }
    if (url === null){
      throw "Url paramater is mandatory in WebSocket objectory implementation";
    }
    onMessageCompleter = new Completer();    
    webSocket = new WebSocket(url);
    
    webSocket.onopen = (){
//      messageProcessingStatus =  GET_CONNECTION_ID;
//      webSocket.onmessage = processMessage;      
//      webSocket.send("Objectory opened");    
      print("in client webSocket.onopen");
      completer.complete(true);//  
    };
  //return Futures.wait([completer.future,onMessageCompleter.future]);
  //  completer.complete(true);
    return completer.future;
  }
  Future get onMessageFuture() => onMessageCompleter.future;
  void processMessage(message){
    var data = message.data;
    print("in process message $data $messageProcessingStatus");

    if (messageProcessingStatus == GET_CONNECTION_ID){      
      socketId = Math.parseInt(data);
      print("socketId  $socketId");
    }
    else {    
      Binary buffer = new Binary.from(data);    
      BsonMap command = new BsonMap(null);
      command.unpackValue(buffer);
      print(command.data);    
    }
    messageProcessingStatus = IDLE_STATUS;
    onMessageCompleter.complete(true);
  }  
  Binary sendMessage(String command, Map obj, [String collection]){    
    Map header = {};    
    if (obj ===  null){
      obj = {};
    }
    header["command"] = command;        
    header["collection"] = collection;    
    BsonMap bHeader = new BsonMap(header);    
    BsonMap bObj = new BsonMap(obj);        
    Binary message = new Binary(bHeader.byteLength()+bObj.byteLength());    
    bHeader.packValue(message);
    bObj.packValue(message);    
    webSocket.send(message.byteList);        
  }
  void save(RootPersistentObject persistentObject){    
    String command = 'update';
    if (persistentObject.id === null){
       command = 'insert';
       persistentObject.id = new ObjectId();
       persistentObject.map["_id"] = persistentObject.id;
    }
    print("sendMessage($command,${persistentObject.map},${persistentObject.type})");
    sendMessage(command,persistentObject.map,persistentObject.type);
  }
  void remove(RootPersistentObject persistentObject){

    if (persistentObject.id === null){
      return;
    }
    sendMessage("remove",{"_id":persistentObject.id},persistentObject.type);
  }
  Future<bool> dropDb(){
    sendMessage("dropDb",{"_id":persistentObject.id},persistentObject.type);
  }
  Future<PersistentObject> findOne(String className,[Map selector]){
    onMessageCompleter = new Completer<PersistentObject>();
    sendMessage("findOne",selector,className);
    messageProcessingStatus = FIND_ONE;
    return onMessageCompleter.Future;  
  }
  future<List<PersistentObject>> find(String className,[Map selector]){
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
  void close(){
    print("Closing objectory");
    webSocket.close(null,"Normal closing, socketId: $socketId");
  }
  Future<List<PersistentObject>> find(String className,[Map selector]){
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
  
  
}
*/