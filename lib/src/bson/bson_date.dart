part of bson;
class BsonDate extends BsonObject{
  DateTime data;
  BsonDate(this.data);
  get value => data;
  byteLength() => 8;
  int get typeByte => BSON.BSON_DATA_DATE;
  packValue(BsonBinary buffer){
     buffer.writeInt64(data.millisecondsSinceEpoch);
  }
  unpackValue(BsonBinary buffer){
     data = new DateTime.fromMillisecondsSinceEpoch(buffer.readInt64());
  }
}