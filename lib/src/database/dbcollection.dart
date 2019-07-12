part of mongo_dart;

class DbCollection {
  Db db;
  String collectionName;

  DbCollection(this.db, this.collectionName) {}

  String fullName() => "${db.databaseName}.$collectionName";

  Future<Map<String, dynamic>> save(Map<String, dynamic> document,
      {WriteConcern writeConcern}) {
    var id;
    bool createId = false;
    if (document.containsKey("_id")) {
      id = document["_id"];
      if (id == null) {
        createId = true;
      }
    }
    if (id != null) {
      return update({"_id": id}, document,
          upsert: true, writeConcern: writeConcern);
    } else {
      if (createId) {
        document["_id"] = ObjectId();
      }
      return insert(document, writeConcern: writeConcern);
    }
  }

  Future<Map<String, dynamic>> insertAll(List<Map<String, dynamic>> documents,
      {WriteConcern writeConcern}) {
    return Future.sync(() {
      MongoInsertMessage insertMessage =
          MongoInsertMessage(fullName(), documents);
      db.executeMessage(insertMessage, writeConcern);
      return db._getAcknowledgement(writeConcern: writeConcern);
    });
  }

  Future<Map<String, dynamic>> update(selector, document,
      {bool upsert = false,
      bool multiUpdate = false,
      WriteConcern writeConcern}) {
    return Future.sync(() {
      int flags = 0;
      if (upsert) {
        flags |= 0x1;
      }
      if (multiUpdate) {
        flags |= 0x2;
      }

      MongoUpdateMessage message = MongoUpdateMessage(
          fullName(), _selectorBuilder2Map(selector), document, flags);
      db.executeMessage(message, writeConcern);
      return db._getAcknowledgement(writeConcern: writeConcern);
    });
  }

  /// Creates a cursor for a query that can be used to iterate over results from MongoDB
  /// ##[selector]
  /// parameter represents query to locate objects. If omitted as in `find()` then query matches all documents in colleciton.
  /// Here's a more selective example:
  ///     find({'last_name': 'Smith'})
  /// Here our selector will match every document where the last_name attribute is 'Smith.'
  ///
  Stream<Map<String, dynamic>> find([selector]) =>
      Cursor(db, this, selector).stream;

  Cursor createCursor([selector]) => Cursor(db, this, selector);

  Future<Map<String, dynamic>> findOne([selector]) {
    Cursor cursor = Cursor(db, this, selector);
    Future<Map<String, dynamic>> result = cursor.nextObject();
    cursor.close();
    return result;
  }

  /// Modifies and returns a single document.
  /// By default, the returned document does not include the modifications made on the update.
  /// To return the document with the modifications made on the update, use the returnNew option.
  Future<Map<String, dynamic>> findAndModify(
      {query, sort, bool remove, update, bool returnNew, fields, bool upsert}) {
    query = _queryBuilder2Map(query);
    sort = _sortBuilder2Map(sort);
    update = _updateBuilder2Map(update);
    fields = _fieldsBuilder2Map(fields);
    return db
        .executeDbCommand(DbCommand.createFindAndModifyCommand(
            db, collectionName,
            query: query as Map<String, dynamic>,
            sort: sort as Map<String, dynamic>,
            remove: remove,
            update: update as Map<String, dynamic>,
            returnNew: returnNew,
            fields: fields as Map<String, dynamic>,
            upsert: upsert))
        .then((reply) {
      return Future.value(reply["value"] as Map<String, dynamic>);
    });
  }

  Future<bool> drop() => db.dropCollection(collectionName);

  Future<Map<String, dynamic>> remove(selector, {WriteConcern writeConcern}) =>
      db.removeFromCollection(
          collectionName, _selectorBuilder2Map(selector), writeConcern);

  Future<int> count([selector]) {
    return db
        .executeDbCommand(DbCommand.createCountCommand(
            db, collectionName, _selectorBuilder2Map(selector)))
        .then((reply) {
      return Future.value((reply["n"] as num)?.toInt());
    });
  }

  Future<Map<String, dynamic>> distinct(String field, [selector]) =>
      db.executeDbCommand(DbCommand.createDistinctCommand(
          db, collectionName, field, _selectorBuilder2Map(selector)));

  Future<Map<String, dynamic>> aggregate(List pipeline,
      {bool allowDiskUse = false, Map<String, dynamic> cursor}) {
    var cmd = DbCommand.createAggregateCommand(db, collectionName, pipeline,
        allowDiskUse: allowDiskUse, cursor: cursor);
    return db.executeDbCommand(cmd);
  }

  Stream<Map<String, dynamic>> aggregateToStream(List pipeline,
      {Map<String, dynamic> cursorOptions = const {},
      bool allowDiskUse = false}) {
    return AggregateCursor(db, this, pipeline, cursorOptions, allowDiskUse)
        .stream;
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> document,
          {WriteConcern writeConcern}) =>
      insertAll([document], writeConcern: writeConcern);

  /// Analogue of mongodb shell method `db.collection.getIndexes()`
  /// Returns an array that holds a list of documents that identify and describe
  /// the existing indexes on the collection. You must call `getIndexes()`
  ///  on a collection
  Future<List<Map<String, dynamic>>> getIndexes() {
    if (db._masterConnection.serverCapabilities.listIndexes) {
      return ListIndexesCursor(db, this).stream.toList();
    } else {
      /// Pre MongoDB v3.0 API
      var selector = <String, dynamic>{};
      selector['ns'] = this.fullName();
      return Cursor(
              db, DbCollection(db, DbCommand.SYSTEM_INDEX_COLLECTION), selector)
          .stream
          .toList();
    }
  }

  Map<String, dynamic> _selectorBuilder2Map(selector) {
    if (selector == null) {
      return <String, dynamic>{};
    }
    if (selector is SelectorBuilder) {
      return selector.map['\$query'] as Map<String, dynamic>;
    }
    return selector as Map<String, dynamic>;
  }

  Map<String, dynamic> _queryBuilder2Map(query) {
    if (query is SelectorBuilder) {
      query = query.map['\$query'];
    }
    return query as Map<String, dynamic>;
  }

  Map<String, dynamic> _sortBuilder2Map(query) {
    if (query is SelectorBuilder) {
      query = query.map['orderby'];
    }
    return query as Map<String, dynamic>;
  }

  Map<String, dynamic> _fieldsBuilder2Map(fields) {
    if (fields is SelectorBuilder) {
      return fields.paramFields;
    }
    return fields as Map<String, dynamic>;
  }

  Map<String, dynamic> _updateBuilder2Map(update) {
    if (update is ModifierBuilder) {
      update = update.map;
    }
    return update as Map<String, dynamic>;
  }
}
