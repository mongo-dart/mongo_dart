part of mongo_dart;

typedef void MonadicBlock(Map value);

class Cursor {

  
  final _log= new Logger('Cursor');
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
  var controller = new StreamController<Map>();

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
      throw new ArgumentError('Expected SelectorBuilder or Map, got $selectorBuilderOrMap');
    }

//    if (!selector.isEmpty && !selector.containsKey(r"$query")){
//        selector = {r"$query": selector};
//    }
    items = new Queue();
  }
  
  MongoQueryMessage generateQueryMessage() {
    return new  MongoQueryMessage(collection.fullName(),
            flags,
            skip,
            limit,
            selector,
            fields);
  }
  
  MongoGetMoreMessage generateGetMoreMessage() {
    return new MongoGetMoreMessage(collection.fullName(), cursorId);
  }

  Map _getNextItem() {
    _returnedCount++;
    return items.removeFirst();
  }
  
  Future<Map> nextObject() {
    if (state == State.INIT) {
      MongoQueryMessage qm = generateQueryMessage();
      return db.queryMessage(qm).then((replyMessage) {
        state = State.OPEN;
        cursorId = replyMessage.cursorId;
        items.addAll(replyMessage.documents);
        if (items.length > 0) {
          return new Future.value(_getNextItem());
        } else{
          return new Future.value(null);
        }
      });
    } else if (state == State.OPEN && limit > 0 && _returnedCount == limit){
      return this.close();
    } else if (state == State.OPEN && items.length > 0){
      return new Future.value(_getNextItem());
    } else if (state == State.OPEN && cursorId > 0){
      var qm = generateGetMoreMessage();
      return db.queryMessage(qm).then((replyMessage){
        state = State.OPEN;
        cursorId = replyMessage.cursorId;
        items.addAll(replyMessage.documents);
        if (items.length > 0){
          return new Future.value(_getNextItem());
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
  
  void _nextEach() {
    nextObject().then((val) {
      if (val == null) {
        eachCallback = null;
        eachComplete.complete(true);
      } else {
        eachCallback(val);
        _nextEach();
      }
    }).catchError((e) {
      eachCallback = null;
      eachComplete.completeError(e);
    });
  }
  
  @deprecated
  Future<bool> each(MonadicBlock callback) => forEach(callback);
  
  Future<bool> forEach(MonadicBlock callback) {
    eachCallback = callback;
    eachComplete = new Completer();
    _nextEach();
    return eachComplete.future;
  }
  
  Future<List<Map>> toList() {
    List<Map> result = [];
    return this.forEach((v)=>result.add(v)).then((v)=> new Future.value(result));
  }
  
  Future close() {
    ////_log.finer("Closing cursor, cursorId = $cursorId");
    state = State.CLOSED;
    if (cursorId != 0){
      MongoKillCursorsMessage msg = new MongoKillCursorsMessage(cursorId);
      cursorId = 0;
      db.queryMessage(msg).catchError((e) => null);
    }
    return new Future.value(null);
  }
  
  Stream<Map> get stream {
    forEach(controller.add)
      .catchError((e) => controller.addError(e))
      .then((_) => controller.close());
    return controller.stream; 
  }
}
