part of bson;
class BsonDate extends BsonObject{
  Date data;
  BsonDate(this.data);
  get value => data;
  byteLength() => 8;
  int get typeByte => BSON.BSON_DATA_DATE;
  packValue(Binary buffer){
     buffer.writeInt64(data.millisecondsSinceEpoch);
  }
  unpackValue(Binary buffer){
     data = new Date.fromMillisecondsSinceEpoch(buffer.readInt64());
  }
}