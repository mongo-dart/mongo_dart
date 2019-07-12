part of mongo_dart;

typedef MonadicBlock = void Function(Map<String, dynamic> value);

class Cursor {
  final _log = Logger('Cursor');
  State state = State.INIT;
  int cursorId = 0;
  Db db;
  Queue<Map<String, dynamic>> items;
  DbCollection collection;
  Map<String, dynamic> selector;
  Map<String, dynamic> fields;
  int skip = 0;
  int limit = 0;
  int _returnedCount = 0;
  Map<String, dynamic> sort;
  Map<String, dynamic> hint;
  MonadicBlock eachCallback;
  var eachComplete;
  bool explain;
  int flags = 0;

  /// Tailable means cursor is not closed when the last data is retrieved
  set tailable(bool value) => value
      ? flags |= MongoQueryMessage.OPTS_TAILABLE_CURSOR
      : flags &= ~(MongoQueryMessage.OPTS_TAILABLE_CURSOR);
  bool get tailable => (flags & MongoQueryMessage.OPTS_TAILABLE_CURSOR) != 0;

  /// Allow query of replica slave. Normally these return an error except for namespace “local”.
  set slaveOk(bool value) => value
      ? flags |= MongoQueryMessage.OPTS_SLAVE
      : flags &= ~(MongoQueryMessage.OPTS_SLAVE);
  bool get slaveOk => (flags & MongoQueryMessage.OPTS_SLAVE) != 0;

  /// The server normally times out idle cursors after an inactivity period (10 minutes)
  /// to prevent excess memory use. Unset this option to prevent that.
  set timeout(bool value) => !value
      ? flags |= MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT
      : flags &= ~(MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT);
  bool get timeout => (flags & MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT) == 0;

  /// If we are at the end of the data, block for a while rather than returning no data.
  /// After a timeout period, we do return as normal, only applicable for tailable cursor.
  set awaitData(bool value) => value
      ? flags |= MongoQueryMessage.OPTS_AWAIT_DATA
      : flags &= ~(MongoQueryMessage.OPTS_AWAIT_DATA);
  bool get awaitData => (flags & MongoQueryMessage.OPTS_AWAIT_DATA) != 0;

  /// Stream the data down full blast in multiple “more” packages,
  /// on the assumption that the client will fully read all data queried.
  /// Faster when you are pulling a lot of data and know you want to pull it all down.
  /// Note: the client is not allowed to not read all the data unless it closes the connection.
  /// TODO Adapt cursor behaviour when enabling exhaust flag
  set exhaust(bool value) => value
      ? flags |= MongoQueryMessage.OPTS_EXHAUST
      : flags &= ~(MongoQueryMessage.OPTS_EXHAUST);
  bool get exhaust => (flags & MongoQueryMessage.OPTS_EXHAUST) != 0;

  /// Get partial results from a mongos if some shards are down (instead of throwing an error)
  set partial(bool value) => value
      ? flags |= MongoQueryMessage.OPTS_PARTIAL
      : flags &= ~(MongoQueryMessage.OPTS_PARTIAL);
  bool get partial => (flags & MongoQueryMessage.OPTS_PARTIAL) != 0;

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
      selector = selectorBuilderOrMap as Map<String, dynamic>;
    } else {
      throw ArgumentError(
          'Expected SelectorBuilder or Map, got $selectorBuilderOrMap');
    }

//    if (!selector.isEmpty && !selector.containsKey(r"$query")){
//        selector = {r"$query": selector};
//    }
    items = Queue();
  }

  MongoQueryMessage generateQueryMessage() {
    return MongoQueryMessage(
        collection.fullName(), flags, skip, limit, selector, fields);
  }

  MongoGetMoreMessage generateGetMoreMessage() {
    return MongoGetMoreMessage(collection.fullName(), cursorId);
  }

  Map<String, dynamic> _getNextItem() {
    _returnedCount++;
    return items.removeFirst();
  }

  void getCursorData(MongoReplyMessage replyMessage) {
    cursorId = replyMessage.cursorId;
    items.addAll(replyMessage.documents);
  }

  Future<Map<String, dynamic>> nextObject() {
    if (state == State.INIT) {
      MongoQueryMessage qm = generateQueryMessage();
      return db.queryMessage(qm).then((replyMessage) {
        state = State.OPEN;
        getCursorData(replyMessage);
        if (items.length > 0) {
          return Future.value(_getNextItem());
        } else {
          return Future.value(null);
        }
      });
    } else if (state == State.OPEN && limit > 0 && _returnedCount == limit) {
      return close();
    } else if (state == State.OPEN && items.length > 0) {
      return Future.value(_getNextItem());
    } else if (state == State.OPEN && cursorId > 0) {
      var qm = generateGetMoreMessage();
      return db.queryMessage(qm).then((replyMessage) {
        state = State.OPEN;
        getCursorData(replyMessage);
        var isDead = (replyMessage.responseFlags ==
                MongoReplyMessage.FLAGS_CURSOR_NOT_FOUND) &&
            (cursorId == 0);
        if (items.length > 0) {
          return Future.value(_getNextItem());
        } else if (tailable && !isDead && awaitData) {
          return Future.value(null);
        } else if (tailable && !isDead) {
          var completer = Completer<Map<String, dynamic>>();
          Timer(Duration(milliseconds: tailableRetryInterval),
              () => completer.complete(null));
          return completer.future;
        } else {
          state = State.CLOSED;
          return Future.value(null);
        }
      });
    } else {
      state = State.CLOSED;
      return Future.value(null);
    }
  }

  Future<Null> close() {
    ////_log.finer("Closing cursor, cursorId = $cursorId");
    state = State.CLOSED;
    if (cursorId != 0) {
      MongoKillCursorsMessage msg = MongoKillCursorsMessage(cursorId);
      cursorId = 0;
      db.executeMessage(msg, WriteConcern.UNACKNOWLEDGED);
    }
    return Future.value(null);
  }

//  Stream<Map> get stream {
//    forEach(controller.add)
//      .catchError((e) => controller.addError(e));
//    return new CursorStream(controller.stream, this);
//  }

  Stream<Map<String, dynamic>> get stream async* {
    Map<String, dynamic> doc = await nextObject();
    while (doc != null) {
      yield doc;
      doc = await nextObject();
    }
  }
}

class CommandCursor extends Cursor {
  CommandCursor(Db db, DbCollection collection, selectorBuilderOrMap)
      : super(db, collection, selectorBuilderOrMap);
  bool firstBatch = true;
  @override
  MongoQueryMessage generateQueryMessage() {
    throw UnimplementedError();
  }

  void getCursorData(MongoReplyMessage replyMessage) {
    if (firstBatch) {
      firstBatch = false;
      var cursorMap = replyMessage.documents.first['cursor'];
      if (cursorMap != null) {
        cursorId = cursorMap['id'] as int;
        final firstBatch = cursorMap['firstBatch'] as List;
        items.addAll(List.from(firstBatch));
      }
    } else {
      super.getCursorData(replyMessage);
    }
  }
}

class AggregateCursor extends CommandCursor {
  List pipeline;
  Map<String, dynamic> cursorOptions;
  bool allowDiskUse;
  AggregateCursor(Db db, DbCollection collection, this.pipeline,
      this.cursorOptions, this.allowDiskUse)
      : super(db, collection, <String, dynamic>{});
  @override
  MongoQueryMessage generateQueryMessage() {
    return DbCommand(
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
    return DbCommand(
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
      : super(db, collection, <String, dynamic>{});
  @override
  MongoQueryMessage generateQueryMessage() {
    return DbCommand(
        db,
        DbCommand.SYSTEM_COMMAND_COLLECTION,
        MongoQueryMessage.OPTS_NO_CURSOR_TIMEOUT,
        0,
        -1,
        {"listIndexes": collection.collectionName},
        null);
  }
}
