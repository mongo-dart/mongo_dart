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

  Future<Map<String, dynamic>> update(selector, document,
      {bool upsert = false,
      bool multiUpdate = false,
      WriteConcern writeConcern}) {
    return Future.sync(() {
      var flags = 0;
      if (upsert) {
        flags |= 0x1;
      }
      if (multiUpdate) {
        flags |= 0x2;
      }

      var message = MongoUpdateMessage(
          fullName(), _selectorBuilder2Map(selector), document, flags);
      db.executeMessage(message, writeConcern);
      return db._getAcknowledgement(writeConcern: writeConcern);
    });
  }

  /// Creates a cursor for a query that can be used to iterate over results
  /// from MongoDB
  /// ##[selector]
  /// parameter represents query to locate objects. If omitted as in `find()`
  /// then query matches all documents in colleciton.
  /// Here's a more selective example:
  ///     find({'last_name': 'Smith'})
  /// Here our selector will match every document where the last_name attribute
  /// is 'Smith.'
  Stream<Map<String, dynamic>> find([selector]) {
    if (db._masterConnectionVerified.serverCapabilities.supportsOpMsg) {
      if (selector is SelectorBuilder) {
        return modernFind(selector: selector);
      } else if (selector is Map<String, dynamic>) {
        return modernFind(filter: selector);
      } else if (selector == null) {
        return modernFind();
      }
      throw MongoDartError('The selector parameter should be either a '
          'SelectorBuilder or a Map<String, dynamic>');
    }
    return legacyFind(selector);
  }

  // Old version to be used on MongoDb versions prior to 3.6
  Stream<Map<String, dynamic>> legacyFind([selector]) =>
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

  Stream<Map<String, dynamic>> aggregateToStream(
      List<Map<String, Object>> pipeline,
      {Map<String, dynamic> cursorOptions = const <String, Object>{},
      bool allowDiskUse = false}) {
    if (db._masterConnectionVerified.serverCapabilities.supportsOpMsg) {
      return modernAggregate(pipeline,
          cursor: cursorOptions,
          aggregateOptions: AggregateOptions(allowDiskUse: allowDiskUse));
    }
    return legacyAggregateToStream(pipeline,
        cursorOptions: cursorOptions, allowDiskUse: allowDiskUse);
  }

  Stream<Map<String, dynamic>> legacyAggregateToStream(List pipeline,
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
    if (res[keyOk] == 0.0) {
      // It should be better to create a MongoDartError,
      // but, for compatibility reasons, we throw the received map.
      throw res;
    }
    if (modernReply) {
      return res;
    }
    return db.getLastError();
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

  // **********************************************************+
  // ************** OP_MSG_COMMANDS ****************************
  // ***********************************************************

  // This method has been made available since version 3.2
  // As we will use this with the new wire message available
  // since version 3.6, we will check this last version
  // in order to allow the execution
  Future<WriteResult> insertOne(Map<String, dynamic> document,
      {WriteConcern writeConcern, bool bypassDocumentValidation}) async {
    if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
      throw MongoDartError('This method is not available before release 3.6');
    }
    return Future.sync(() {
      var insertOneOptions = InsertOneOptions(
          writeConcern: writeConcern,
          bypassDocumentValidation: bypassDocumentValidation);

      var insertOneOperation = InsertOneOperation(this, document,
          insertOneOptions: insertOneOptions);

      return insertOneOperation.executeDocument();
    });
  }

  // This method has been made available since version 3.2
  // As we will use this with the new wire message available
  // since version 3.6, we will check this last version
  // in order to allow the execution
  Future<BulkWriteResult> insertMany(List<Map<String, dynamic>> documents,
      {WriteConcern writeConcern,
      bool ordered,
      bool bypassDocumentValidation}) async {
    if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
      throw MongoDartError('This method is not available before release 3.6');
    }
    return Future.sync(() {
      var insertManyOptions = InsertManyOptions(
          writeConcern: writeConcern,
          ordered: ordered,
          bypassDocumentValidation: bypassDocumentValidation);

      var insertManyOperation = InsertManyOperation(this, documents,
          insertManyOptions: insertManyOptions);

      return insertManyOperation.executeDocument();
    });
  }

  // Find operation with the new OP_MSG (starting from release 3.6)
  Stream<Map<String, dynamic>> modernFind(
      {SelectorBuilder selector,
      Map<String, Object> filter,
      Map<String, Object> sort,
      Map<String, Object> projection,
      String hint,
      Map<String, Object> hintDocument,
      int skip,
      int limit,
      FindOptions findOptions,
      Map<String, Object> rawOptions}) {
    if (!db._masterConnection.serverCapabilities.supportsOpMsg) {
      throw MongoDartError('At least MongoDb version 3.6 is required '
          'to run the find operation');
    }

    var operation = FindOperation(this,
        filter:
            filter ?? (selector?.map == null ? null : selector.map[keyQuery]),
        sort: sort ?? (selector?.map == null ? null : selector.map['orderby']),
        projection: projection ?? selector?.paramFields,
        hint: hint,
        hintDocument: hintDocument,
        limit: limit ?? selector?.paramLimit,
        skip: skip ??
            (selector != null && selector.paramSkip > 0
                ? selector.paramSkip
                : null),
        findOptions: findOptions,
        rawOptions: rawOptions);

    return ModernCursor(operation).stream;
  }

  /// This method returns a stream that can be read or transformed into
  /// a list with `.toList()`
  ///
  /// It corresponds to the legacy method `aggregateToStream()`.
  ///
  /// The pipeline can be either an `AggregationPipelineBuilder` or a
  /// List of Maps (`List<Map<String, Object>>`)
  Stream<Map<String, dynamic>> modernAggregate(dynamic pipeline,
          {bool explain,
          Map<String, Object> cursor,
          String hint,
          Map<String, Object> hintDocument,
          AggregateOptions aggregateOptions,
          Map<String, Object> rawOptions}) =>
      modernAggregateCursor(pipeline,
              explain: explain,
              cursor: cursor,
              hint: hint,
              hintDocument: hintDocument,
              aggregateOptions: aggregateOptions,
              rawOptions: rawOptions)
          .stream;

  /// This method returns a curosr that can be read or transformed into
  /// a stream with `stream` (for a stream you can directly call
  /// `modernAggregate`)
  ///
  /// It corresponds to the legacy method `aggregate()`
  ///
  /// The pipeline can be either an `AggregationPipelineBuilder` or a
  /// List of Maps (`List<Map<String, Object>>`)
  ModernCursor modernAggregateCursor(dynamic pipeline,
      {bool explain,
      Map<String, Object> cursor,
      String hint,
      Map<String, Object> hintDocument,
      AggregateOptions aggregateOptions,
      Map<String, Object> rawOptions}) {
    if (!db._masterConnection.serverCapabilities.supportsOpMsg) {
      throw MongoDartError('At least MongoDb version 3.6 is required '
          'to run the aggregate operation');
    }
    return ModernCursor(AggregateOperation(pipeline,
        collection: this,
        explain: explain,
        cursor: cursor,
        hint: hint,
        hintDocument: hintDocument,
        aggregateOptions: aggregateOptions,
        rawOptions: rawOptions));
  }

  Stream watch(Object pipeline,
          {int batchSize,
          String hint,
          Map<String, Object> hintDocument,
          ChangeStreamOptions changeStreamOptions,
          Map<String, Object> rawOptions}) =>
      watchCursor(pipeline,
              batchSize: batchSize,
              hint: hint,
              hintDocument: hintDocument,
              changeStreamOptions: changeStreamOptions,
              rawOptions: rawOptions)
          .changeStream;

  ModernCursor watchCursor(Object pipeline,
          {int batchSize,
          String hint,
          Map<String, Object> hintDocument,
          ChangeStreamOptions changeStreamOptions,
          Map<String, Object> rawOptions}) =>
      ModernCursor(ChangeStreamOperation(pipeline,
          collection: this,
          hint: hint,
          hintDocument: hintDocument,
          changeStreamOptions: changeStreamOptions,
          rawOptions: rawOptions));

  Future<BulkWriteResult> bulkWrite(List<Map<String, Object>> documents,
      {bool ordered}) async {
    ordered ??= true;

    Bulk bulk;
    if (ordered) {
      bulk = OrderedBulk(this);
    } else {
      bulk = UnorderedBulk(this);
    }
    var index = -1;
    for (var document in documents) {
      index++;
      if (document.isEmpty) {
        continue;
      }
      var key = document.keys.first;
      switch (key) {

        /// { insertOne : { "document" : {
        ///     "_id" : 4, "char" : "Dithras", "class" : "barbarian", "lvl" : 4
        /// } } }
        case bulkInsertOne:
          var docMap = document[key];
          if (docMap is Map<String, Object>) {
            var contentMap = docMap[bulkDocument];
            if (contentMap is Map<String, Object>) {
              bulk.insertOne(contentMap);
            } else {
              throw MongoDartError('The "$bulkDocument" key of the '
                  '"$bulkInsertOne" element at index $index must '
                  'contain a Map');
            }
          } else {
            throw MongoDartError('The "$bulkInsertOne" element at index '
                '$index must contain a Map');
          }
          break;
        case bulkInsertMany:
          var docMap = document[key];
          if (docMap is Map<String, Object>) {
            var contentList = docMap[bulkDocuments];
            if (contentList is List<Map<String, Object>>) {
              bulk.insertMany(contentList);
            } else {
              throw MongoDartError('The "$bulkDocuments" key of the '
                  '"$bulkInsertMany" element at index $index must '
                  'contain a List of Maps');
            }
          } else {
            throw MongoDartError('The "$bulkInsertMany" element at index '
                '$index must contain a Map');
          }
          break;
        case bulkUpdateOne:
          throw StateError(
              'The operation "$bulkUpdateOne" is Still to be developed');
          break;
        case bulkUpdateMany:
          throw StateError(
              'The operation "$bulkUpdateMany" is Still to be developed');
          break;
        case bulkReplaceOne:
          throw StateError(
              'The operation "$bulkReplaceOne" is Still to be developed');
          break;
        case bulkDeleteOne:
          var docMap = document[key];
          if (docMap is Map<String, Object>) {
            var contentMap = docMap[bulkFilter];
            if (contentMap is Map<String, Object>) {
              bulk.deleteOne(DeleteOneRequest(contentMap));
            } else {
              throw MongoDartError('The "$bulkFilter" key of the '
                  '"$bulkDeleteOne" element at index $index must '
                  'contain a Map');
            }
          } else {
            throw MongoDartError('The "$bulkDeleteOne" element at index '
                '$index must contain a Map');
          }
          break;
        case bulkDeleteMany:
          var docMap = document[key];
          if (docMap is Map<String, Object>) {
            var contentMap = docMap[bulkFilter];
            if (contentMap is Map<String, Object>) {
              bulk.deleteMany(DeleteManyRequest(contentMap));
            } else {
              throw MongoDartError('The "$bulkFilter" key of the '
                  '"$bulkDeleteMany" element at index $index must '
                  'contain a Map');
            }
          } else {
            throw MongoDartError('The "$bulkDeleteMany" element at index '
                '$index must contain a Map');
          }
          break;
        default:
          throw StateError('The operation "$key" is not allowed in bulkWrite');
      }
    }

    return bulk.executeDocument();
  }
}
