#import("dart:io");

void main() {  
  WebSocket webSocket;
  webSocket = new WebSocket("ws://localhost:8080/");
  webSocket.onopen = (){
    webSocket.send("Objectory opened");
    webSocket.send([123,234,23,34,45]);
    webSocket.close(123,"Normal closing");
  };
}