interface ObjectId default BsonObjectId{
  ObjectId();
  ObjectId.fromSeconds(int seconds);  
  ObjectId.fromHexString(String hexString);
  int hashCode();  
  String toHexString();
}