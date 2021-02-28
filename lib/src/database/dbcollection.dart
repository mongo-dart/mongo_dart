part of mongo_dart;

class DbCollection {
  Db db;
  String collectionName;
  ReadPreference readPreference = ReadPreference.primary;

  DbCollection(this.db, this.collectionName);

  String fullName() => '${db.databaseName}.$collectionName';

  @Deprecated('Since version 4.2. Use insertOne() or replaceOne() instead.')
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
      return legacyUpdate({'_id': id}, document,
          upsert: true, writeConcern: writeConcern);
    } else {
      if (createId) {
        document['_id'] = ObjectId();
      }
      return insert(document, writeConcern: writeConcern);
    }
  }

  /// Allows to insert many documents at a time.
  /// This is the legacy version of the insertMany() method
  Future<Map<String, dynamic>> insertAll(List<Map<String, dynamic>> documents,
      {WriteConcern writeConcern}) async {
    if (db._masterConnectionVerified.serverCapabilities.supportsOpMsg) {
      await insertMany(documents, writeConcern: writeConcern);
      return db._getAcknowledgement(writeConcern: writeConcern);
    }
    return legacyInsertAll(documents, writeConcern: writeConcern);
  }

  /// Allows to insert many documents at a time.
  /// This is the legacy version of the insertMany() method
  Future<Map<String, dynamic>> legacyInsertAll(
      List<Map<String, dynamic>> documents,
      {WriteConcern writeConcern}) {
    return Future.sync(() {
      var insertMessage = MongoInsertMessage(fullName(), documents);
      db.executeMessage(insertMessage, writeConcern);
      return db._getAcknowledgement(writeConcern: writeConcern);
    });
  }

  /// Modifies an existing document or documents in a collection.
  /// The method can modify specific fields of an existing document or
  /// documents or replace an existing document entirely,
  /// depending on the `document` parameter.
  ///
  /// By default, the `update()` method updates a single document.
  /// Include the option multiUpdate: true to update all documents that match
  /// the query criteria.
  Future<Map<String, dynamic>> update(selector, document,
      {bool upsert = false,
      bool multiUpdate = false,
      WriteConcern writeConcern}) async {
    if (db._masterConnectionVerified.serverCapabilities.supportsOpMsg) {
      await modernUpdate(selector, document,
          upsert: upsert, multi: multiUpdate, writeConcern: writeConcern);
      return db._getAcknowledgement();
    }
    return legacyUpdate(selector, document,
        upsert: upsert, multiUpdate: multiUpdate, writeConcern: writeConcern);
  }

  // Old version to be used on MongoDb versions prior to 3.6
  Future<Map<String, dynamic>> legacyUpdate(selector, document,
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

  // Old version to be used on MongoDb versions prior to 3.6
  Cursor createCursor([selector]) => Cursor(db, this, selector);

  /// Returns one document that satisfies the specified query criteria on the
  /// collection or view. If multiple documents satisfy the query,
  /// this method returns the first document.
  Future<Map<String, dynamic>> findOne([selector]) {
    if (db._masterConnectionVerified.serverCapabilities.supportsOpMsg) {
      if (selector is SelectorBuilder) {
        return modernFindOne(selector: selector);
      } else if (selector is Map<String, dynamic>) {
        return modernFindOne(filter: selector);
      } else if (selector == null) {
        return modernFindOne();
      }
      throw MongoDartError('The selector parameter should be either a '
          'SelectorBuilder or a Map<String, dynamic>');
    }
    return legacyFindOne(selector);
  }

  // Old version to be used on MongoDb versions prior to 3.6
  Future<Map<String, dynamic>> legacyFindOne([selector]) {
    var cursor = Cursor(db, this, selector);
    var result = cursor.nextObject();
    cursor.close();
    return result;
  }

  /// Modifies and returns a single document.
  /// By default, the returned document does not include the modifications
  /// made on the update.
  /// To return the document with the modifications made on the update,
  /// use the returnNew option.
  Future<Map<String, dynamic>> findAndModify(
      {query,
      sort,
      bool remove,
      update,
      bool returnNew,
      fields,
      bool upsert}) async {
    if (db._masterConnectionVerified.serverCapabilities.supportsOpMsg) {
      var result = await modernFindAndModify(
          query: query,
          sort: sort,
          remove: remove,
          update: update,
          returnNew: returnNew,
          fields: fields,
          upsert: upsert);
      return result.value;
    }

    return legacyFindAndModify(
        query: query,
        sort: sort,
        remove: remove,
        update: update,
        returnNew: returnNew,
        fields: fields,
        upsert: upsert);
  }

  // Old version to be used on MongoDb versions prior to 3.6
  Future<Map<String, dynamic>> legacyFindAndModify(
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

  /// Removes documents from a collection.
  Future<Map<String, dynamic>> remove(selector,
      {WriteConcern writeConcern}) async {
    if (db._masterConnectionVerified.serverCapabilities.supportsOpMsg) {
      var result = await deleteMany(
        selector,
        writeConcern: writeConcern,
      );
      return result.serverResponses.first;
    }
    return legacyRemove(selector, writeConcern: writeConcern);
  }

  // Old version to be used on MongoDb versions prior to 3.6
  Future<Map<String, dynamic>> legacyRemove(selector,
          {WriteConcern writeConcern}) =>
      db.removeFromCollection(
          collectionName, _selectorBuilder2Map(selector), writeConcern);

  // Todo - missing modern version
  Future<int> count([selector]) {
    return db
        .executeDbCommand(DbCommand.createCountCommand(
            db, collectionName, _selectorBuilder2Map(selector)))
        .then((reply) {
      return Future.value((reply['n'] as num)?.toInt());
    });
  }

  // Todo - missing modern version
  Future<Map<String, dynamic>> distinct(String field, [selector]) =>
      db.executeDbCommand(DbCommand.createDistinctCommand(
          db, collectionName, field, _selectorBuilder2Map(selector)));

  /// Old version to be used on MongoDb versions prior to 3.6
  Future<Map<String, dynamic>> aggregate(List pipeline,
      {bool allowDiskUse = false, Map<String, dynamic> cursor}) {
    var cmd = DbCommand.createAggregateCommand(db, collectionName, pipeline,
        allowDiskUse: allowDiskUse, cursor: cursor);
    return db.executeDbCommand(cmd);
  }

  /// Executes an aggregation pipeline
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

  /// Old version to be used on MongoDb versions prior to 3.6
  Stream<Map<String, dynamic>> legacyAggregateToStream(List pipeline,
      {Map<String, dynamic> cursorOptions = const {},
      bool allowDiskUse = false}) {
    return AggregateCursor(db, this, pipeline, cursorOptions, allowDiskUse)
        .stream;
  }

  /// Inserts a document into a collection
  Future<Map<String, dynamic>> insert(Map<String, dynamic> document,
      {WriteConcern writeConcern}) async {
    if (db._masterConnectionVerified.serverCapabilities.supportsOpMsg) {
      await insertOne(document, writeConcern: writeConcern);
      return db._getAcknowledgement(writeConcern: writeConcern);
    }
    return legacyInsert(document, writeConcern: writeConcern);
  }

  /// Old version to be used on MongoDb versions prior to 3.6
  Future<Map<String, dynamic>> legacyInsert(Map<String, dynamic> document,
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
      return selector.map['\$query'] as Map<String, dynamic> ??
          <String, dynamic>{};
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

  // ****************************************************************+
  // ******************** OP_MSG_COMMANDS ****************************
  // *****************************************************************
  // All the following methods are available starting from release 3.6
  // *****************************************************************

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

  Future<WriteResult> deleteOne(selector,
      {WriteConcern writeConcern,
      CollationOptions collation,
      String hint,
      Map<String, Object> hintDocument}) async {
    var deleteOperation = DeleteOneOperation(
        this,
        DeleteOneStatement(_selectorBuilder2Map(selector),
            collation: collation, hint: hint, hintDocument: hintDocument),
        deleteOneOptions: DeleteOneOptions(writeConcern: writeConcern));
    return deleteOperation.executeDocument();
  }

  Future<WriteResult> deleteMany(selector,
      {WriteConcern writeConcern,
      CollationOptions collation,
      String hint,
      Map<String, Object> hintDocument}) async {
    var deleteOperation = DeleteManyOperation(
        this,
        DeleteManyStatement(_selectorBuilder2Map(selector),
            collation: collation, hint: hint, hintDocument: hintDocument),
        deleteManyOptions: DeleteManyOptions(writeConcern: writeConcern));
    return deleteOperation.executeDocument();
  }

  Future<Map<String, dynamic>> modernUpdate(selector, update,
      {bool upsert,
      bool multi,
      WriteConcern writeConcern,
      CollationOptions collation,
      List<dynamic> arrayFilters,
      String hint,
      Map<String, Object> hintDocument}) async {
    var updateOperation = UpdateOperation(
        this,
        [
          UpdateStatement(_selectorBuilder2Map(selector),
              update is List ? update : _updateBuilder2Map(update),
              upsert: upsert,
              multi: multi,
              collation: collation,
              arrayFilters: arrayFilters,
              hint: hint,
              hintDocument: hintDocument)
        ],
        updateOptions: UpdateOptions(writeConcern: writeConcern));
    return updateOperation.execute();
  }

  Future<WriteResult> replaceOne(selector, update,
      {bool upsert,
      WriteConcern writeConcern,
      CollationOptions collation,
      String hint,
      Map<String, Object> hintDocument}) async {
    var replaceOneOperation = ReplaceOneOperation(
        this,
        ReplaceOneStatement(_selectorBuilder2Map(selector),
            update is List ? update : _updateBuilder2Map(update),
            upsert: upsert,
            collation: collation,
            hint: hint,
            hintDocument: hintDocument),
        replaceOneOptions: ReplaceOneOptions(writeConcern: writeConcern));
    return replaceOneOperation.executeDocument();
  }

  Future<WriteResult> updateOne(selector, update,
      {bool upsert,
      WriteConcern writeConcern,
      CollationOptions collation,
      List<dynamic> arrayFilters,
      String hint,
      Map<String, Object> hintDocument}) async {
    var updateOneOperation = UpdateOneOperation(
        this,
        UpdateOneStatement(_selectorBuilder2Map(selector),
            update is List ? update : _updateBuilder2Map(update),
            upsert: upsert,
            collation: collation,
            arrayFilters: arrayFilters,
            hint: hint,
            hintDocument: hintDocument),
        updateOneOptions: UpdateOneOptions(writeConcern: writeConcern));
    return updateOneOperation.executeDocument();
  }

  Future<WriteResult> updateMany(selector, update,
      {bool upsert,
      WriteConcern writeConcern,
      CollationOptions collation,
      List<dynamic> arrayFilters,
      String hint,
      Map<String, Object> hintDocument}) async {
    var updateManyOperation = UpdateManyOperation(
        this,
        UpdateManyStatement(_selectorBuilder2Map(selector),
            update is List ? update : _updateBuilder2Map(update),
            upsert: upsert,
            collation: collation,
            arrayFilters: arrayFilters,
            hint: hint,
            hintDocument: hintDocument),
        updateManyOptions: UpdateManyOptions(writeConcern: writeConcern));
    return updateManyOperation.executeDocument();
  }

  Future<FindAndModifyResult> modernFindAndModify(
      {query,
      sort,
      bool remove,
      update,
      bool returnNew,
      fields,
      bool upsert,
      List arrayFilters,
      String hint,
      Map<String, Object> hintDocument,
      FindAndModifyOptions findAndModifyOptions,
      Map<String, Object> rawOptions}) async {
    if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
      throw MongoDartError('This method is not available before release 3.6');
    }

    var famOperation = FindAndModifyOperation(this,
        query: _queryBuilder2Map(query),
        sort: _sortBuilder2Map(sort),
        remove: remove,
        update: update is List ? update : _updateBuilder2Map(update),
        returnNew: returnNew,
        fields: _fieldsBuilder2Map(fields),
        upsert: upsert,
        arrayFilters: arrayFilters,
        hint: hint,
        hintDocument: hintDocument,
        findAndModifyOptions: findAndModifyOptions,
        rawOptions: rawOptions);
    return famOperation.executeDocument();
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
            filter ?? (selector?.map == null ? null : selector.map[key$Query]),
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

  /// Returns one document that satisfies the specified query criteria on
  /// the collection or view. If multiple documents satisfy the query,
  /// this method returns the first document according to the sort order
  /// or the natural order of sort parameter is not specified.
  /// In capped collections, natural order is the same as insertion order.
  /// If no document satisfies the query, the method returns null.
  ///
  /// In MongoDb this method only allows the filter and the projection
  /// parameters.
  /// This version has more parameters, and it is essentially a wrapper
  /// araound the find method with a fixed limit set to 1 that returns
  /// a document instead of a stream.
  Future<Map<String, dynamic>> modernFindOne(
      {SelectorBuilder selector,
      Map<String, Object> filter,
      Map<String, Object> sort,
      Map<String, Object> projection,
      String hint,
      Map<String, Object> hintDocument,
      int skip,
      FindOptions findOptions,
      Map<String, Object> rawOptions}) async {
    if (!db._masterConnection.serverCapabilities.supportsOpMsg) {
      throw MongoDartError('At least MongoDb version 3.6 is required '
          'to run the findOne operation');
    }

    var operation = FindOperation(this,
        filter:
            filter ?? (selector?.map == null ? null : selector.map[key$Query]),
        sort: sort ?? (selector?.map == null ? null : selector.map['orderby']),
        projection: projection ?? selector?.paramFields,
        hint: hint,
        hintDocument: hintDocument,
        limit: 1,
        skip: skip ??
            (selector != null && selector.paramSkip > 0
                ? selector.paramSkip
                : null),
        findOptions: findOptions,
        rawOptions: rawOptions);

    return ModernCursor(operation).nextObject();
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
      {bool ordered, WriteConcern writeConcern}) async {
    ordered ??= true;

    Bulk bulk;
    if (ordered) {
      bulk = OrderedBulk(this, writeConcern: writeConcern);
    } else {
      bulk = UnorderedBulk(this, writeConcern: writeConcern);
    }
    var index = -1;
    for (var document in documents) {
      index++;
      if (document.isEmpty) {
        continue;
      }
      var key = document.keys.first;
      var testMap = document[key];
      if (testMap is! Map<String, dynamic>) {
        throw MongoDartError('The "$key" element at index '
            '$index must contain a Map');
      }
      Map<String, dynamic> docMap = testMap;

      switch (key) {
        case bulkInsertOne:
          if (docMap[bulkDocument] is! Map<String, dynamic>) {
            throw MongoDartError('The "$bulkDocument" key of the '
                '"$bulkInsertOne" element at index $index must '
                'contain a Map');
          }
          bulk.insertOne(docMap[bulkDocument]);

          break;
        case bulkInsertMany:
          if (docMap[bulkDocuments] is! List<Map<String, dynamic>>) {
            throw MongoDartError('The "$bulkDocuments" key of the '
                '"$bulkInsertMany" element at index $index must '
                'contain a List of Maps');
          }
          bulk.insertMany(docMap[bulkDocuments]);
          break;
        case bulkUpdateOne:
          bulk.updateOneFromMap(docMap, index);
          break;
        case bulkUpdateMany:
          bulk.updateManyFromMap(docMap, index);
          break;
        case bulkReplaceOne:
          bulk.replaceOneFromMap(docMap, index);
          break;
        case bulkDeleteOne:
          bulk.deleteOneFromMap(docMap, index);
          break;
        case bulkDeleteMany:
          bulk.deleteManyFromMap(docMap, index);
          break;
        default:
          throw StateError('The operation "$key" is not allowed in bulkWrite');
      }
    }

    return bulk.executeDocument();
  }
}
