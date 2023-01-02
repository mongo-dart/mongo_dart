import '../base/mongo_database.dart';

class MongoDatabaseV1 extends MongoDatabase {
  MongoDatabaseV1(super.mongoClient, super.databaseName) : super.protected();
}
