part of mongo_dart;

class DbCollection {
  Db db;
  String collectionName;
  ReadPreference readPreference = ReadPreference.primary;

  DbCollection(this.db, this.collectionName);

  String fullName() => '${db.databaseName}.$collectionName';

  Future<Map<String, dynamic>> save(Map<String, dynamic> document,
      {WriteConcern writeConcern}) {
    var id;
    var createId = false;
    if (document.containsKey('_id')) {
      id = document['_id'];
      if (id == null) {
        createId = true;
      }
    }
    if (id != null) {
      return update({'_id': id}, document,
          upsert: true, writeConcern: writeConcern);
    } else {
      if (createId) {
        document['_id'] = ObjectId();
      }
      return insert(document, writeConcern: writeConcern);
    }
  }

  Future<Map<String, dynamic>> insertAll(List<Map<String, dynamic>> documents,
      {WriteConcern writeConcern}) {
    return Future.sync(() {
      var insertMessage = MongoInsertMessage(fullName(), documents);
      db.executeMessage(insertMessage, writeConcern);
      return db._getAcknowledgement(writeConcern: writeConcern);
    });
  }

  /// The update command modifies documents in a collection.
  ///
  /// [selector] is the query that matches documents to update.
  /// Use the same query selectors as used in the find() method.
  ///
  /// [document] is the modifications to apply. Can be either a document
  /// or pipeline.
  ///
  /// [ordered] is optional. If true, then when an update statement fails,
  /// return without performing the remaining update statements.
  /// If false, then when an update fails, continue with the remaining
  /// update statements, if any.
  ///
  /// [writeConcern] is optional. A document expressing the write concern
  /// of the update command. Omit to use the default write concern.
  /// Do not explicitly set the write concern for the operation if run in a
  /// transaction. To use write concern with transactions, see official docs.
  ///
  /// [bypassDocumentValidation] is optional. Enables update to bypass
  /// document validation during the operation.
  /// This lets you update documents that do not meet the
  /// validation requirements. Version >= 3.2
  ///
  /// [comment] is optional. A user-provided comment to attach to this command.
  ///
  /// [upsert] is optional. If true, perform an insert if no documents match
  /// the query. If both upsert and multi are true and no documents match
  /// the query, the update operation inserts only a single document.
  ///
  /// [multi] is optional. If true, updates all documents that meet
  /// the query criteria. If false, limit the update to one document that
  /// meet the query criteria. Defaults to false.
  ///
  /// [collation] is optional. Specifies the collation to use for the
  /// operation. Collation allows users to specify language-specific rules
  /// for string comparison, such as rules for lettercase and accent marks.
  ///
  /// [arrayFilters] is optional. An array of filter documents that
  /// determines which array elements to modify for an update operation
  /// on an array field.
  ///
  /// [hint] is optional. A document or string that specifies the index
  /// to use to support the query predicate. The option can take an index
  /// specification document or the index name string.
  /// If you specify an index that does not exist, the operation errors.
  ///
  /// Return example:
  /// ```json
  ///  {
  ///    "ok" : 1,
  ///    "nModified" : 0,
  ///    "n" : 1,
  ///    "upserted" : [
  ///       {
  ///          "index" : 0,
  ///          "_id" : ObjectId("52ccb2118908ccd753d65882")
  ///       }
  ///    ]
  ///  }
  /// ```
  ///
  /// See more at the official docs:
  /// https://docs.mongodb.com/manual/reference/command/update/
  Future<Map<String, dynamic>> update(Map<String, Object> selector,
      Object document,
      {bool upsert = false,
        bool multiUpdate = false,
        Map<String, Object> collation,
        Iterable arrayFilters, dynamic hint,
        WriteConcern writeConcern, bool ordered = true,
        bool bypassDocumentValidation, dynamic comment}) {
    var data = <String, Object>{
      keyUpdate: collectionName,
      keyDatabaseName: db.databaseName,
      keyOrdered: ordered,
      if (bypassDocumentValidation != null)
        keyBypassDocumentValidation: bypassDocumentValidation,
      if (comment != null)
        keyComment: comment,
      if (writeConcern != null)
        keyWriteConcern: writeConcern.asMap(db.masterConnection.serverStatus),
      keyUpdateArgument: [
        {
          keyUpdateQuery: selector,
          keyUpdateDocument: document,
          keyUpsert: upsert,
          keyUpdateMulti: multiUpdate,
          if (arrayFilters != null)
            keyArrayFilters: arrayFilters,
          if (collation != null)
            keyCollation: collation,
          if (hint != null)
            keyHint: hint
        }
      ]
    };

    return db.executeModernMessage(MongoModernMessage(data));
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
    var cursor = Cursor(db, this, selector);
    var result = cursor.nextObject();
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
      return Future.value(reply['value'] as Map<String, dynamic>);
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
      return Future.value((reply['n'] as num)?.toInt());
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
      selector['ns'] = fullName();
      return Cursor(
              db, DbCollection(db, DbCommand.SYSTEM_INDEX_COLLECTION), selector)
          .stream
          .toList();
    }
  }

  /// This function is provided for all servers starting from version 3.6
  /// For previous releases use the same method on Db class.
  ///
  /// The modernReply flag allows the caller to receive the result of
  /// the command without a call to getLastError().
  /// As the format is different from the getLastError() one, for compatibility
  /// reasons, if you specify false, the old format is returned
  /// (but one more getLastError() is performed).
  /// Example of the new format:
  /// {createdCollectionAutomatically: false,
  /// numIndexesBefore: 2,
  /// numIndexesAfter: 3,
  /// ok: 1.0}
  ///
  /// Example of the old format:
  /// {"connectionId" -> 11,
  /// "n" -> 0,
  /// "syncMillis" -> 0,
  /// "writtenTo" -> null,
  /// "err" -> null,
  /// "ok" -> 1.0}
  Future<Map<String, dynamic>> createIndex(
      {String key,
      Map<String, dynamic> keys,
      bool unique,
      bool sparse,
      bool background,
      bool dropDups,
      Map<String, dynamic> partialFilterExpression,
      String name,
      bool modernReply}) async {
    if (!db._masterConnection.serverCapabilities.supportsOpMsg) {
      throw MongoDartError('Use createIndex() method on db (before 3.6)');
    }
    return Future.sync(() async {
      modernReply ??= true;
      var indexOptions = CreateIndexOptions(this,
          uniqueIndex: unique == true,
          sparseIndex: sparse == true,
          background: background == true,
          dropDuplicatedEntries: dropDups == true,
          partialFilterExpression: partialFilterExpression,
          indexName: name);

      var indexOperation =
          CreateIndexOperation(db, this, _setKeys(key, keys), indexOptions);

      var res = await indexOperation.execute();
      if (modernReply) {
        return res;
      }
      return db.getLastError();
    });
  }

  // This method has been made available since version 3.2
  // As we will use this with the new wire message available
  // since version 3.6, we will check this last version
  // in order to allow the execution
  Future<Map<String, dynamic>> insertOne(Map<String, dynamic> document,
      {WriteConcern writeConcern}) async {
    if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
      throw MongoDartError('This method is not available before release 3.6');
    }
    return Future.sync(() {
      var insertOneOptions =
          InsertOneOptions(this, writeConcern: writeConcern);

      var insertOneOperation =
          InsertOneOperation(this, document, insertOneOptions);

      return insertOneOperation.execute();
    });
  }

  Map<String, dynamic> _setKeys(String key, Map<String, dynamic> keys) {
    if (key != null && keys != null) {
      throw ArgumentError('Only one parameter must be set: key or keys');
    }

    if (key != null) {
      keys = {};
      keys['$key'] = 1;
    }

    if (keys == null) {
      throw ArgumentError('key or keys parameter must be set');
    }

    return keys;
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
