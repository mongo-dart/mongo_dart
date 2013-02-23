part of bson;
class Timestamp extends BsonObject{
  int seconds;
  int increment;
  Timestamp([this.seconds,this.increment]){
    if (seconds == null){
      seconds = (new DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt();
    }
    if (increment == null){
      increment = Statics.nextIncrement;
    }
  }
  String toString()=>"Timestamp(seconds: $seconds, increment: $increment)";
  int byteLength() => 8;
  packValue(BsonBinary buffer){
    buffer.writeInt(seconds);
    buffer.writeInt(increment);    
  }
  unpackValue(BsonBinary buffer){
     seconds = buffer.readInt32();
     increment = buffer.readInt32();     
  }
}
