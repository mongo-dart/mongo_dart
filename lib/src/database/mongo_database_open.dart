import 'base/mongo_database.dart';

class MongoDatabaseOpen extends MongoDatabase {
  MongoDatabaseOpen(super.mongoClient, super.databaseName) : super.protected();
}
