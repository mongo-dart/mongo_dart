interface ObjectId default BsonObjectId{
  ObjectId();
  ObjectId.fromSeconds(int seconds);  
  int hashCode();  
  String toHexString();
}