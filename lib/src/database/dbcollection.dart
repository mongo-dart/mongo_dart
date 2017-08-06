part of mongo_dart;

class DbCollection {
  Db db;
  String collectionName;
  DbCollection(this.db, this.collectionName) {}
  String fullName() => "${db.databaseName}.$collectionName";

  Future<Map> save(Map document, {WriteConcern writeConcern}) {
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
        document["_id"] = new ObjectId();
      }
      return insert(document, writeConcern: writeConcern);
    }
  }

  Future<Map> insertAll(List<Map> documents, {WriteConcern writeConcern}) {
    return new Future.sync(() {
      MongoInsertMessage insertMessage =
          new MongoInsertMessage(fullName(), documents);
      db.executeMessage(insertMessage, writeConcern);
      return db._getAcknowledgement(writeConcern: writeConcern);
    });
  }

  Future<Map> update(selector, document,
      {bool upsert: false,
      bool multiUpdate: false,
      WriteConcern writeConcern}) {
    return new Future.sync(() {
      int flags = 0;
      if (upsert) {
        flags |= 0x1;
      }
      if (multiUpdate) {
        flags |= 0x2;
      }

      MongoUpdateMessage message = new MongoUpdateMessage(
          fullName(), _selectorBuilder2Map(selector), document, flags);
      db.executeMessage(message, writeConcern);
      return db._getAcknowledgement(writeConcern: writeConcern);
    });
  }

  /**
  * Creates a cursor for a query that can be used to iterate over results from MongoDB
  * ##[selector]
  * parameter represents query to locate objects. If omitted as in `find()` then query matches all documents in colleciton.
  * Here's a more selective example:
  *     find({'last_name': 'Smith'})
  * Here our selector will match every document where the last_name attribute is 'Smith.'
  *
  */
  Stream<Map> find([selector]) => new Cursor(db, this, selector).stream;
  Cursor createCursor([selector]) => new Cursor(db, this, selector);

  Future<Map> findOne([selector]) {
    Cursor cursor = new Cursor(db, this, selector);
    Future<Map> result = cursor.nextObject();
    cursor.close();
    return result;
  }

  /**
   * Modifies and returns a single document.
   * By default, the returned document does not include the modifications made on the update.
   * To return the document with the modifications made on the update, use the returnNew option.
   */
  Future<Map> findAndModify(
      {query, sort, bool remove, update, bool returnNew, fields, bool upsert}) {
    query = _queryBuilder2Map(query);
    sort = _sortBuilder2Map(sort);
    update = _updateBuilder2Map(update);
    fields = _fieldsBuilder2Map(fields);
    return db
        .executeDbCommand(DbCommand.createFindAndModifyCommand(
            db, collectionName,
            query: query,
            sort: sort,
            remove: remove,
            update: update,
            returnNew: returnNew,
            fields: fields,
            upsert: upsert))
        .then((reply) {
      return new Future.value(reply["value"]);
    });
  }

  Future<bool> drop() => db.dropCollection(collectionName);

  Future<Map> remove(selector, {WriteConcern writeConcern}) =>
      db.removeFromCollection(
          collectionName, _selectorBuilder2Map(selector), writeConcern);

  Future<int> count([selector]) {
    return db
        .executeDbCommand(DbCommand.createCountCommand(
            db, collectionName, _selectorBuilder2Map(selector)))
        .then((reply) {
      return new Future.value(reply["n"].toInt());
    });
  }

  Future<Map> distinct(String field, [selector]) =>
      db.executeDbCommand(DbCommand.createDistinctCommand(
          db, collectionName, field, _selectorBuilder2Map(selector)));

  Future<Map> aggregate(List pipeline, {allowDiskUse: false}) {
    var cmd = DbCommand.createAggregateCommand(db, collectionName, pipeline,
        allowDiskUse: allowDiskUse);
    return db.executeDbCommand(cmd);
  }

  Stream<Map> aggregateToStream(List pipeline,
      {Map cursorOptions: const {}, bool allowDiskUse: false}) {
    return new AggregateCursor(db, this, pipeline, cursorOptions, allowDiskUse)
        .stream;
  }

  Future<Map> insert(Map document, {WriteConcern writeConcern}) =>
      insertAll([document], writeConcern: writeConcern);

  /// Analogue of mongodb shell method `db.collection.getIndexes()`
  /// Returns an array that holds a list of documents that identify and describe
  /// the existing indexes on the collection. You must call `getIndexes()`
  ///  on a collection
  Future<List<Map>> getIndexes() {
    if (db._masterConnection.serverCapabilities.listIndexes) {
      return new ListIndexesCursor(db, this).stream.toList();
    } else {
      /// Pre MongoDB v3.0 API
      var selector = {};
      selector['ns'] = this.fullName();
      return new Cursor(db,
              new DbCollection(db, DbCommand.SYSTEM_INDEX_COLLECTION), selector)
          .stream
          .toList();
    }
  }

  Map _selectorBuilder2Map(selector) {
    if (selector == null) {
      return {};
    }
    if (selector is SelectorBuilder) {
      return selector.map['\$query'];
    }
    return selector;
  }

  Map _queryBuilder2Map(query) {
    if (query is SelectorBuilder) {
      query = query.map['\$query'];
    }
    return query;
  }

  Map _sortBuilder2Map(query) {
    if (query is SelectorBuilder) {
      query = query.map['orderby'];
    }
    return query;
  }

  Map _fieldsBuilder2Map(fields) {
    if (fields is SelectorBuilder) {
      return fields.paramFields;
    }
    return fields;
  }

  Map _updateBuilder2Map(update) {
    if (update is ModifierBuilder) {
      update = update.map;
    }
    return update;
  }
}
