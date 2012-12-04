part of mongo_dart;
typedef MonadicBlock(var value);
class Cursor{

static const INIT = 0;
static const OPEN = 1;
static const CLOSED = 2;


  int state = INIT;
  int cursorId = 0;
  Db db;
  Queue items;
  DbCollection collection;
  Map selector;
  Map fields;
  int skip = 0;
  int limit = 0;
  Map sort;
  Map hint;
  MonadicBlock eachCallback;
  var eachComplete;
  bool explain;
  int flags = 0;
  Cursor(this.db, this.collection, selectorBuilderOrMap){
    if (selectorBuilderOrMap == null){
      selector = {};
    } else if (selectorBuilderOrMap is SelectorBuilder) {
      selector = selectorBuilderOrMap.map;
      fields = selectorBuilderOrMap.extParams.fields;
      limit = selectorBuilderOrMap.extParams.limit;
      skip = selectorBuilderOrMap.extParams.skip;
    } else if (selectorBuilderOrMap is Map) {
      selector = selectorBuilderOrMap;
    } else {
      throw new ArgumentError('Expected SelectorBuilder or Map, got $selectorBuilderOrMap');
    }

    if (!selector.isEmpty && !selector.containsKey("query")){
        selector = {"query": selector};
    }
    items = new Queue();
  }
  MongoQueryMessage generateQueryMessage(){
    return new  MongoQueryMessage(collection.fullName(),
            flags,
            skip,
            limit,
            selector,
            fields);
  }
  MongoGetMoreMessage generateGetMoreMessage(){
    return new  MongoGetMoreMessage(collection.fullName(),
            cursorId);
  }


  Map _getNextItem(){
    return items.removeFirst();
  }
  Future<Map> nextObject(){
    if (state == INIT){
      Completer<Map> nextItem = new Completer<Map>();
      MongoQueryMessage qm = generateQueryMessage();
      Future<MongoReplyMessage> reply = db.queryMessage(qm);
      reply.then((replyMessage){
        state = OPEN;
        //print("${replyMessage.cursorId}");
        cursorId = replyMessage.cursorId;
        items.addAll(replyMessage.documents);
        if (items.length > 0){
          Map nextDoc = _getNextItem();
          _log.finer("Cursor _getNextItem $nextDoc");
          nextItem.complete(nextDoc);
        }
        else{
          nextItem.complete(null);
        }
      });
      return nextItem.future;
    }
    else if (state == OPEN && items.length > 0){
      return new Future.immediate(_getNextItem());
    }
    else if (state == OPEN && cursorId > 0){
      Completer nextItem = new Completer();
      var qm = generateGetMoreMessage();
      Future<MongoReplyMessage> reply = db.queryMessage(qm);
      reply.then((replyMessage){
        state = OPEN;
        cursorId = replyMessage.cursorId;
        items.addAll(replyMessage.documents);
        if (items.length > 0){
          nextItem.complete(_getNextItem());
        }
        else{
          state = CLOSED;
          nextItem.complete(null);
        }
      });
      return nextItem.future;
    }
    else {
      state = CLOSED;
      return new Future.immediate(null);
    }
  }
  void _nextEach(){
    nextObject().then((val){
      if (val == null){
        eachCallback = null;
        eachComplete.complete(true);
      } else {
        eachCallback(val);
        _nextEach();
      }
    });
  }

  Future<bool> each(MonadicBlock callback){
    eachCallback = callback;
    eachComplete = new Completer();
    _nextEach();
    return eachComplete.future;
  }
  Future<List<Map>> toList(){
    List<Map> result = [];
    Completer completer = new Completer();
    this.each((v)=>result.addLast(v)).then((v)=>completer.complete(result));
    return completer.future;
  }
  Future close(){
    _log.finer("Closing cursor, cursorId = $cursorId");
    state = CLOSED;
    if (cursorId != 0){
      MongoKillCursorsMessage msg = new MongoKillCursorsMessage(cursorId);
      cursorId = 0;
      return db.queryMessage(msg);
    }
  }
}