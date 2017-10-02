part of mongo_dart;

typedef void MonadicBlock(Map value);

class Cursor {
  final _log = new Logger('Cursor');
  State state = State.INIT;
  int cursorId = 0;
  Db db;
  Queue items;
  DbCollection collection;
  Map selector;
  Map fields;
  int skip = 0;
  int limit = 0;
  int _returnedCount = 0;
  Map sort;
  Map hint;
  MonadicBlock eachCallback;
  var eachComplete;
  bool explain;
  int flags = 0;

  /// Tailable means cursor is not closed when the last data is retrieved
  set tailable(bool value) => value
      ? flags |= MongoQueryMessage.OPTS_TAILABLE_CURSOR
      : flags &= ~(MongoQueryMessage.OPTS_TAILABLE_CURSOR);
  get tailable => (flags & MongoQueryMessage.OPTS_TAILABLE_CURSOR) != 0;

  /// Allow query of replica slave. Normally these return an error except for namespace “local”.
  set slaveOk(bool value) => value
      ? flags |= MongoQueryMessage.OPTS_SLAVE
      : flags &= ~(MongoQueryMessage.OPTS_SLAVE);
  get slaveOk => (flags & MongoQueryMessage.OPTS_SLAVE) != 0;

  /// The server normally times out idle cursors after an inactivity period (10 minutes)
  /// to prevent excess memory use. Unset this option to prevent that.
  set timeout(bool value) => !value
      ? flags |= MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT
      : flags &= ~(MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT);
  get timeout => (flags & MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT) == 0;

  /// If we are at the end of the data, block for a while rather than returning no data.
  /// After a timeout period, we do return as normal, only applicable for tailable cursor.
  set awaitData(bool value) => value
      ? flags |= MongoQueryMessage.OPTS_AWAIT_DATA
      : flags &= ~(MongoQueryMessage.OPTS_AWAIT_DATA);
  get awaitData => (flags & MongoQueryMessage.OPTS_AWAIT_DATA) != 0;

  /// Stream the data down full blast in multiple “more” packages,
  /// on the assumption that the client will fully read all data queried.
  /// Faster when you are pulling a lot of data and know you want to pull it all down.
  /// Note: the client is not allowed to not read all the data unless it closes the connection.
  /// TODO Adapt cursor behaviour when enabling exhaust flag
  set exhaust(bool value) => value
      ? flags |= MongoQueryMessage.OPTS_EXHAUST
      : flags &= ~(MongoQueryMessage.OPTS_EXHAUST);
  get exhaust => (flags & MongoQueryMessage.OPTS_EXHAUST) != 0;

  /// Get partial results from a mongos if some shards are down (instead of throwing an error)
  set partial(bool value) => value
      ? flags |= MongoQueryMessage.OPTS_PARTIAL
      : flags &= ~(MongoQueryMessage.OPTS_PARTIAL);
  get partial => (flags & MongoQueryMessage.OPTS_PARTIAL) != 0;

  /// Specify the miliseconds between getMore on tailable cursor, only applicable when awaitData isn't set.
  /// Default value is 100 ms
  int tailableRetryInterval = 100;

  Cursor(this.db, this.collection, selectorBuilderOrMap) {
    if (selectorBuilderOrMap == null) {
      selector = {};
    } else if (selectorBuilderOrMap is SelectorBuilder) {
      selector = selectorBuilderOrMap.map;
      fields = selectorBuilderOrMap.paramFields;
      limit = selectorBuilderOrMap.paramLimit;
      skip = selectorBuilderOrMap.paramSkip;
    } else if (selectorBuilderOrMap is Map) {
      selector = selectorBuilderOrMap;
    } else {
      throw new ArgumentError(
          'Expected SelectorBuilder or Map, got $selectorBuilderOrMap');
    }

//    if (!selector.isEmpty && !selector.containsKey(r"$query")){
//        selector = {r"$query": selector};
//    }
    items = new Queue();
  }

  MongoQueryMessage generateQueryMessage() {
    return new MongoQueryMessage(
        collection.fullName(), flags, skip, limit, selector, fields);
  }

  MongoGetMoreMessage generateGetMoreMessage() {
    return new MongoGetMoreMessage(collection.fullName(), cursorId);
  }

  Map _getNextItem() {
    _returnedCount++;
    return items.removeFirst();
  }

  void getCursorData(MongoReplyMessage replyMessage) {
    cursorId = replyMessage.cursorId;
    items.addAll(replyMessage.documents);
  }

  Future<Map> nextObject() {
    if (state == State.INIT) {
      MongoQueryMessage qm = generateQueryMessage();
      return db.queryMessage(qm).then((replyMessage) {
        state = State.OPEN;
        getCursorData(replyMessage);
        if (items.length > 0) {
          return new Future.value(_getNextItem());
        } else {
          return new Future.value(null);
        }
      });
    } else if (state == State.OPEN && limit > 0 && _returnedCount == limit) {
      return this.close();
    } else if (state == State.OPEN && items.length > 0) {
      return new Future.value(_getNextItem());
    } else if (state == State.OPEN && cursorId > 0) {
      var qm = generateGetMoreMessage();
      return db.queryMessage(qm).then((replyMessage) {
        state = State.OPEN;
        getCursorData(replyMessage);
        var isDead = (replyMessage.responseFlags ==
                MongoReplyMessage.FLAGS_CURSOR_NOT_FOUND) &&
            (cursorId == 0);
        if (items.length > 0) {
          return new Future.value(_getNextItem());
        } else if (tailable && !isDead && awaitData) {
          return new Future.value(null);
        } else if (tailable && !isDead) {
          var completer = new Completer<Map>();
          new Timer(new Duration(milliseconds: tailableRetryInterval),
              () => completer.complete(null));
          return completer.future;
        } else {
          state = State.CLOSED;
          return new Future.value(null);
        }
      });
    } else {
      state = State.CLOSED;
      return new Future.value(null);
    }
  }

  Future close() {
    ////_log.finer("Closing cursor, cursorId = $cursorId");
    state = State.CLOSED;
    if (cursorId != 0) {
      MongoKillCursorsMessage msg = new MongoKillCursorsMessage(cursorId);
      cursorId = 0;
      db.executeMessage(msg, WriteConcern.UNACKNOWLEDGED);
    }
    return new Future.value(null);
  }

//  Stream<Map> get stream {
//    forEach(controller.add)
//      .catchError((e) => controller.addError(e));
//    return new CursorStream(controller.stream, this);
//  }

  Stream<Map> get stream async* {
    Map doc = await nextObject();
    while (doc != null) {
      yield doc;
      doc = await nextObject();
    }
  }
}

class CommandCursor extends Cursor {
  CommandCursor(db, collection, selectorBuilderOrMap)
      : super(db, collection, selectorBuilderOrMap);
  bool firstBatch = true;
  @override
  MongoQueryMessage generateQueryMessage() {
    throw new UnimplementedError();
  }

  void getCursorData(MongoReplyMessage replyMessage) {
    if (firstBatch) {
      firstBatch = false;
      var cursorMap = replyMessage.documents.first['cursor'];
      if (cursorMap != null) {
        cursorId = cursorMap['id'];
        items.addAll(cursorMap['firstBatch']);
      }
    } else {
      super.getCursorData(replyMessage);
    }
  }
}

class AggregateCursor extends CommandCursor {
  List pipeline;
  Map cursorOptions;
  bool allowDiskUse;
  AggregateCursor(
      db, collection, this.pipeline, this.cursorOptions, this.allowDiskUse)
      : super(db, collection, {});
  @override
  MongoQueryMessage generateQueryMessage() {
    return new DbCommand(
        db,
        DbCommand.SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT,
        0,
        -1,
        {
          'aggregate': collection.collectionName,
          'pipeline': pipeline,
          'cursor': cursorOptions,
          'allowDiskUse': this.allowDiskUse
        },
        null);
  }
}

class ListCollectionsCursor extends CommandCursor {
  ListCollectionsCursor(Db db, selector) : super(db, null, selector);
  @override
  MongoQueryMessage generateQueryMessage() {
    return new DbCommand(
        db,
        DbCommand.SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT,
        0,
        -1,
        {'listCollections': 1, 'filter': selector},
        null);
  }
}

class ListIndexesCursor extends CommandCursor {
  ListIndexesCursor(Db db, DbCollection collection)
      : super(db, collection, const {});
  @override
  MongoQueryMessage generateQueryMessage() {
    return new DbCommand(
        db,
        DbCommand.SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT,
        0,
        -1,
        {"listIndexes": collection.collectionName},
        null);
  }
}
