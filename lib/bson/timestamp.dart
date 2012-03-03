class Timestamp extends BsonObject{  
  int seconds;
  int increment;  
  Timestamp([this.seconds,this.increment]){
    if (seconds === null){
      seconds = (new Date.now().value / 1000).toInt();
    }
    if (increment === null){
      increment = Statics.nextIncrement;
    }          
  }
  String toString()=>"Timestamp(seconds: $seconds, increment: $increment)";
  int byteLength() => 8;  
}
