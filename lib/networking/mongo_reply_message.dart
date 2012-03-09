class MongoReplyMessage extends MongoMessage{
  BsonCString _collectionFullName;
  int responseFlags;
  // 64bit integer
  int cursorId =-1; 
  int startingFrom;
  int numberReturned = -1;
  List documents;  
  deserialize(Binary buffer){
    readMessageHeaderFrom(buffer);
    responseFlags = buffer.readInt32();
    cursorId = buffer.readInt64();
    startingFrom = buffer.readInt32();
    numberReturned = buffer.readInt32();
    documents = new List(numberReturned);
    for (int n=0;n<numberReturned;n++){
      BsonMap doc = new BsonMap({});
      doc.unpackValue(buffer);
      documents[n] = doc.value;
    }
  }
}