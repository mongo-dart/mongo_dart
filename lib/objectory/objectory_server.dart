#import('dart:io');
#import("../mongo.dart");
#import("../bson/bson.dart");

Map<String, String> contentTypes = const {
  "html": "text/html; charset=UTF-8",
  "dart": "application/dart",
  "js": "application/javascript", 
};

List<WebSocketConnection> connections;
void processMessage(message){
  print("in process message $message");
  if (message is String){
    print(message);    
  }
  else{    
    Binary buffer = new Binary.from(message);    
    BsonMap command = new BsonMap(null);
    command.unpackValue(buffer);
    print(command.data);    
  }
}
void main() {
  connections = new List();
  
  WebSocketHandler wsHandler = new WebSocketHandler();
  wsHandler.onOpen = (WebSocketConnection conn) {
    print("Connection opened. Connections total: ${connections.length}");
    connections.add(conn);    
    conn.onClosed = (a, b) => removeConnection(conn);
    conn.onError = (_) => removeConnection(conn);
    conn.send("234234234");    
    conn.onMessage = processMessage;
    
  };

  HttpServer server = new HttpServer();
  server.addRequestHandler((_) => true, wsHandler.onRequest);   

  server.listen("127.0.0.1", 8080);  
}
void removeConnection(WebSocketConnection conn) {
  int index = connections.indexOf(conn);
  if (index > -1) {
    connections.removeRange(index, 1);
  }
}