#import("../lib/mongo.dart");
#import("../lib/bson/bson.dart");
#import("dart:io");
main(){
  Connection conn = new Connection();
  conn.connect();
  MongoQueryMessage queryMessage = new MongoQueryMessage("db.\$cmd",0,0,0xffffffff,{"ping":0x1},null);
/*
  Binary buffer = queryMessage.serialize();
  print(buffer.toHexString());
  Expect.stringEquals('350000000200000000000000d407000000000000746573742e24636d640000000000ffffffff0f0000001070696e67000100000000',
    buffer.toHexString());
*/    
  //print(conn.sendMessage(buffer));
  conn.query(queryMessage,(reply)=>print(reply.documents));
}