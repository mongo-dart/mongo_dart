#import('dart:io');
#import("../mongo.dart");
#import("../bson/bson.dart");

final PORT = 8080;
final DATABASE = 'OBJECTORY_WS_TEST';
final IPADDRESS = '127.0.0.1';


class ObjectoryServer {
  Db db;
    ObjectoryServer(){
      db = new Db(DATABASE);
      db.open().then((v){
      WebSocketHandler wsHandler = new WebSocketHandler();
      wsHandler.onOpen = (WebSocketConnection conn) {
        conn.onError = (e) => print("onError: $e");
        conn.onClosed = (a,b) => print("onClosed: $a, $b");  
        conn.onMessage = (m) => processMessage(m,conn);    
      };
      HttpServer server = new HttpServer();
      server.addRequestHandler((_) => true, wsHandler.onRequest);   
      server.listen(IPADDRESS, PORT);  
    });  
  }
  void processMessage(message, WebSocketConnection connection){
    if (message is String){
      print(message);    
    }
    else{    
      Binary buffer = new Binary.from(message);    
      BsonMap header = new BsonMap(null);
      header.unpackValue(buffer);
      print("Header: ${header.value}");    
      BsonMap obj = new BsonMap(null);
      obj.unpackValue(buffer);
      print("Obj: ${obj.value}");
      String command = header.value["command"];
      processMongoCommand(header.value["command"], header.value["collection"], obj.value, connection);
    }    
  }
  void processMongoCommand(String command,String collection, Map obj, WebSocketConnection connection){
    if (command == "insert"){
      db.collection(collection).insert(obj);
    }
    if (command == "remove"){
      db.collection(collection).remove(obj);
    }
    if (command == "dropDb"){
      db.drop();
    }  
    if (command == "update"){
      db.collection(collection).update(obj);
    }
    if (command == "findOne"){
      db.collection(collection).findOne(obj).then((val)=>sendObject(connection,val));
    }
  }
  sendObject(WebSocketConnection connection, Map val){
  }
}
void main() {
  var server = new ObjectoryServer();
}
