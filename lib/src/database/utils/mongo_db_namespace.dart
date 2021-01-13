import 'package:mongo_dart/src/database/utils/map_keys.dart';

class MongoDBNamespace {
  final String db;
  final String collection;

  MongoDBNamespace(this.db, [this.collection]);

  factory MongoDBNamespace.fromString(String namespace) {
    if (namespace == null) {
      throw ArgumentError('Cannot parse namespace from "$namespace"');
    }

    var parts = namespace.split('.');
    return MongoDBNamespace(parts.first, parts.length > 1 ? parts[1] : null);
  }


  factory MongoDBNamespace.fromMap(Map<String, Object> namespaceMap) {
    if (namespaceMap == null) {
      throw ArgumentError('Cannot parse namespace from "$namespaceMap"');
    }

    return MongoDBNamespace(namespaceMap[keyDb], namespaceMap[keyColl]);
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
      MongoDBNamespace(db, collection);
}
