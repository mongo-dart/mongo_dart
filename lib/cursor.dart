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
  List items;
  MCollection collection;
  Map selector;
  Map fields;
  int skip;
  int limit;
  Map sort;
  Map hint;
  var eachCallback;
  var eachComplete;
  bool explain;
  int flags = 0;  
  Cursor(this.db, this.collection, [this.selector, this.fields, this.skip=0, this.limit=1
  , this.sort, this.hint, this.explain]){
    if (selector === null){
      selector = {};
    }
    items = [];
  }
  MongoQueryMessage generateQueryMessage(){
    return new  MongoQueryMessage(collection.fullName(),
            flags,
            skip,
            limit,
            selector,
            fields);
  }
  getNextItem(){
    return items.removeLast();
  }
  Future nextObject(){
    if (state == INIT){
      Completer nextItem = new Completer();
      MongoQueryMessage qm = generateQueryMessage();
      Future<MongoReplyMessage> reply = db.executeQueryMessage(qm);
      reply.then((replyMessage){
        state = OPEN;
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
    else {
      state = CLOSED;
      return new Future.immediate(null);
    }
  }
  nextTick(Timer timer){
    nextObject().then((val){
      if (val === null){
          eachCallback = null;
         eachComplete.complete(true);
      } else {
            eachCallback(val);
            nextTick(null);
//            new Timer(nextTick,0);
      }            
    });
  }
  Future<bool> each(callback){
    eachCallback = callback; 
    eachComplete = new Completer();
//     new Timer(nextTick,0);
    nextTick(null);
    return eachComplete.future;
  }
}