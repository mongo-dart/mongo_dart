#import("../../lib/bson/bson.dart");
main(){
  Expect.isTrue(bsonObjectFrom(1234) is BsonInt);
  Expect.isTrue(bsonObjectFrom("asdfasdf") is BsonString);
}