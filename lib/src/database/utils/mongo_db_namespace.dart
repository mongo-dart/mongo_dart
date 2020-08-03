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
