import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

class MongoDBNamespace {
  final String db;
  final String? collection;

  MongoDBNamespace(this.db, {this.collection});

  factory MongoDBNamespace.fromString(String namespace) {
    var parts = namespace.split('.');
    return MongoDBNamespace(parts.first,
        collection: parts.length > 1 ? parts[1] : null);
  }

  factory MongoDBNamespace.fromMap(Map<String, Object> namespaceMap) {
    if (namespaceMap[keyDb] == null) {
      throw MongoDartError('Missing database name (element $keyDb) in Map');
    }
    return MongoDBNamespace(namespaceMap[keyDb] as String,
        collection: namespaceMap[keyColl] as String?);
  }

  @override
  String toString() {
    var collectionName = collection ?? '';
    if (collectionName.isEmpty) {
      return db;
    }
    return '$db.$collectionName';
  }

  MongoDBNamespace withCollection(String collection) =>
      MongoDBNamespace(db, collection: collection);
}
