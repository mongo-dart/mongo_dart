part of mongo_dart;

class DbCommand extends MongoQueryMessage {
  // Constants
  static final SYSTEM_NAMESPACE_COLLECTION = "system.namespaces";
  static final SYSTEM_INDEX_COLLECTION = "system.indexes";
  static final SYSTEM_PROFILE_COLLECTION = "system.profile";
  static final SYSTEM_USER_COLLECTION = "system.users";
  static final SYSTEM_COMMAND_COLLECTION = "\$cmd";

  Db db;
  DbCommand(
      this.db,
      String collectionName,
      int flags,
      int numberToSkip,
      int numberToReturn,
      Map<String, dynamic> query,
      Map<String, dynamic> fields)
      : super(collectionName, flags, numberToSkip, numberToReturn, query,
            fields) {
    _collectionFullName = BsonCString("${db.databaseName}.$collectionName");
  }

  static DbCommand createFindAndModifyCommand(Db db, String collectionName,
      {Map<String, dynamic> query,
      Map<String, dynamic> sort,
      bool remove,
      Map<String, dynamic> update,
      bool returnNew,
      Map<String, dynamic> fields,
      bool upsert}) {
    Map<String, dynamic> command = {"findandmodify": collectionName};
    if (query != null) {
      command['query'] = query;
    }
    if (sort != null) {
      command['sort'] = sort;
    }
    if (remove != null) {
      command['remove'] = remove;
    }
    if (update != null) {
      command['update'] = update;
    }
    if (returnNew != null) {
      command['new'] = returnNew;
    }
    if (fields != null) {
      command['fields'] = fields;
    }
    if (upsert != null) {
      command['upsert'] = upsert;
    }
    return DbCommand(db, SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT, 0, -1, command, null);
  }

  static DbCommand createDropCollectionCommand(Db db, String collectionName) {
    return DbCommand(
        db,
        SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT,
        0,
        -1,
        {'drop': collectionName},
        null);
  }

  static DbCommand createDropDatabaseCommand(Db db) {
    return DbCommand(
        db,
        SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT,
        0,
        -1,
        {'dropDatabase': 1},
        null);
  }

  static DbCommand createQueryDbCommand(Db db, Map<String, dynamic> command) {
    return DbCommand(db, SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT, 0, 1, command, null);
  }

  static MongoQueryMessage createQueryAdminCommand(
      Map<String, dynamic> command) {
    return MongoQueryMessage("admin.$SYSTEM_COMMAND_COLLECTION",
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT, 0, 1, command, null);
  }

  static DbCommand createDBSlaveOKCommand(Db db, Map<String, dynamic> command) {
    return DbCommand(
        db,
        SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT | MongoQueryMessage.OPTS_SLAVE,
        0,
        -1,
        command,
        null);
  }

  static DbCommand createPingCommand(Db db) {
    return createQueryDbCommand(db, {'ping': 1});
  }

  static DbCommand createGetNonceCommand(Db db) {
    return createQueryDbCommand(db, {'getnonce': 1});
  }

  static DbCommand createBuildInfoCommand(Db db) {
    return createQueryDbCommand(db, {'buildInfo': 1});
  }

  static DbCommand createGetLastErrorCommand(Db db, WriteConcern concern) {
    return createQueryDbCommand(db, concern.command);
  }

  static DbCommand createCountCommand(Db db, String collectionName,
      [Map<String, dynamic> selector = const {}]) {
    var finalQuery = <String, dynamic>{};
    finalQuery["count"] = collectionName;
    finalQuery["query"] = selector;
    return DbCommand(db, SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT, 0, -1, finalQuery, null);
  }

  static DbCommand createSaslStartCommand(
      Db db, String mechanismName, Uint8List bytesToSendToServer) {
    var command = {
      'saslStart': 1,
      'mechanism': mechanismName,
      'payload': base64.encode(bytesToSendToServer)
    };

    return DbCommand(db, SYSTEM_COMMAND_COLLECTION, MongoQueryMessage.OPTS_NONE,
        0, -1, command, null);
  }

  static DbCommand createSaslContinueCommand(
      Db db, int conversationId, Uint8List bytesToSendToServer) {
    var command = {
      'saslContinue': 1,
      'conversationId': conversationId,
      'payload': base64.encode(bytesToSendToServer)
    };

    return DbCommand(db, SYSTEM_COMMAND_COLLECTION, MongoQueryMessage.OPTS_NONE,
        0, -1, command, null);
  }

  static DbCommand createDistinctCommand(
      Db db, String collectionName, String field,
      [Map<String, dynamic> selector = const {}]) {
    return DbCommand(
        db,
        SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT,
        0,
        -1,
        {'distinct': collectionName, 'key': field, 'query': selector},
        null);
  }

  static DbCommand createAggregateCommand(
      Db db, String collectionName, List pipeline,
      {bool allowDiskUse = false, Map<String, dynamic> cursor}) {
    var query = {'aggregate': collectionName, 'pipeline': pipeline};

    if (cursor != null) query['cursor'] = cursor;

    if (db._masterConnection.serverCapabilities.aggregationCursor) {
      query["allowDiskUse"] = allowDiskUse;
    }

    return DbCommand(db, SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT, 0, -1, query, null);
  }

  static DbCommand createIsMasterCommand(Db db) {
    return createQueryDbCommand(db, {'ismaster': 1});
  }
}
