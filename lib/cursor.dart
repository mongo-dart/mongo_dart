typedef MonadicBlock(var value);
class Cursor{
/**
 * Init state
 *  
 * @classconstant INIT
 **/
static final INIT = 0;

/**
 * Cursor open
 *  
 * @classconstant OPEN
 **/
static final OPEN = 1;

/**
 * Cursor closed
 *  
 * @classconstant CLOSED
 **/
static final CLOSED = 2;


  int state = INIT;
  int cursorId = 0;
  Db db;
  Queue items;
  DbCollection collection;
  Map selector;
  Map fields;
  int skip;
  int limit;
  Map sort;
  Map hint;
  MonadicBlock eachCallback;
  var eachComplete;
  bool explain;
  int flags = 0;  
  Cursor(this.db, this.collection, [this.selector, this.fields, this.skip=0, this.limit=0
  , this.sort, this.hint, this.explain]){
    if (selector === null){
      selector = {};
    } else{
      if (!selector.containsKey("query")){
        selector = {"query": selector};
      }          
    }
    if (sort !== null){
      selector["orderby"] = sort;
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
  
  
  getNextItem(){
    return items.removeFirst();
  }
  Future nextObject(){
    if (state == INIT){
      Completer nextItem = new Completer();
      MongoQueryMessage qm = generateQueryMessage();
      Future<MongoReplyMessage> reply = db.executeQueryMessage(qm);
      reply.then((replyMessage){
        state = OPEN;
        //print("${replyMessage.cursorId}");
        cursorId = replyMessage.cursorId;
        items.addAll(replyMessage.documents);
        if (items.length > 0){
          nextItem.complete(getNextItem());
        }
        else{
          nextItem.complete(null);
        }
      });
      return nextItem.future;
    }  
    else if (state == OPEN && items.length > 0){
      return new Future.immediate(getNextItem());
    }
    else if (state == OPEN && cursorId > 0){
      Completer nextItem = new Completer();
      var qm = generateGetMoreMessage();
      Future<MongoReplyMessage> reply = db.executeQueryMessage(qm);
      reply.then((replyMessage){
        state = OPEN;
        cursorId = replyMessage.cursorId;
        items.addAll(replyMessage.documents);
        if (items.length > 0){
          nextItem.complete(getNextItem());
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
  nextEach(){
    nextObject().then((val){
      if (val === null){
        eachCallback = null;
        eachComplete.complete(true);
      } else {
        eachCallback(val);
        nextEach();
      }            
    });
  }
  
  Future<bool> each(MonadicBlock callback){
    eachCallback = callback; 
    eachComplete = new Completer();
    nextEach();
    return eachComplete.future;
  }
  Future<List<Map>> toList(){
    List<Map> result = [];
    Completer completer = new Completer();
    this.each((v)=>result.addLast(v)).then((v)=>completer.complete(result));
    return completer.future;    
  }
  close(){
    debug("Closing cursor, cursorId = $cursorId");
    if (cursorId != 0){      
      MongoKillCursorsMessage msg = new MongoKillCursorsMessage(cursorId);
      db.executeMessage(msg);
      cursorId = 0;
    } 
    state = CLOSED;
  }
}