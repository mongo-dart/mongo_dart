part of mongo_dart; 

/**
 * Eases access to MongoDB initialization and operation methods.
 */
class MongoClient {
  String uri = 'mongodb://127.0.0.1';
  String dbName;  
  String collName; 
  SelectorBuilder query = new SelectorBuilder();
  
  //String projection;      
  //String cursorModifier   
  
  Db db;
  DbCollection collection;
  
  /**
   * Initializes database parameters. By default, connection uri is set to 
   * mongodb://127.0.0.1. Can be overridden by passing a string to [uri].
   */
  MongoClient(String dbName, String collName, [String uri]) {
    this.dbName = dbName; 
    this.collName = collName;
    
    if (uri != null) {
      this.uri = uri;
    }
  }      
  
  //Accessor methods
  /**
   * Opens a connection to db for advanced use cases. To avoid memory leaks, you should
   * close the connection when no longer needed with the [close] method.
   */
  Future openDb() {
    db = new Db('$uri\/${dbName}');
    collection = db.collection(collName);
      
    return db
      .open();
  }
  
  /**
   * Returns a list of results that matches the query.
   */
  Future<List<Map>> find([SelectorBuilder query]) {
    var cursor = collection.find(query);
    
    return cursor
      .toList()
      .then((List<Map> list) {
        return list;
      });
  }
  
  /**
   * Returns a single result that matches the query.
   */
  Future<Map> findOne([SelectorBuilder query]) {
    var cursor = collection.findOne(query);  
    return cursor;
  }  
  
  /**
   * Inserts a single document.
   */
  Future insert(Map document, {WriteConcern writeConcern} ) {
    var confirmMsg = collection.insert(document, writeConcern: writeConcern);  
    return confirmMsg;
  }
  
  /**
   * Inserts a list of documents.
   */
  Future insertAll(List<Map> documents, {WriteConcern writeConcern}) {
    var confirmMsg = collection.insertAll(documents, writeConcern: writeConcern); 
    return confirmMsg;
  }
  
  /**
   * Updates a single document based on query results. 
   * 
   * Can optionally [upsert] to insert document if not found, and/or [multiUpdate] to update multiple 
   * documents that match the query.
   */
  Future update(SelectorBuilder query, Map document, {bool upsert, bool multiUpdate, WriteConcern
      writeConcern}) {
    if (upsert == null) {
      upsert = false;
    } 
    
    if (multiUpdate == null) {
      multiUpdate = false;
    }
      
    var confirmMsg = collection.update(query, document, upsert: upsert, multiUpdate: multiUpdate,
      writeConcern: writeConcern);
    
    return confirmMsg;
  }
  
  /**
   * Updates a list of documents based on query results. Accepts queryDocs, a map in which the key is a query
   * and its value is the document to be updated.
   *  
   * Can optionally [upsert] to insert document if not found, and/or [multiUpdate] to update multiple 
   * documents that match the query. 
   */
  
   Future updateAll(List<Map<SelectorBuilder, Map>> queryDocList, {bool upsert, bool multiUpdate, WriteConcern
       writeConcern}) {
    if (upsert == null) {
      upsert = false;
    } 
    
    if (multiUpdate == null) {
      multiUpdate = false;
    }
    
    var futureList = [];
    
    return Future
      .forEach(queryDocList, (Map queryDoc) {
        var operation = db
          .collection(collName)
          .update(queryDoc.keys.single, queryDoc.values.single, upsert: upsert, multiUpdate: multiUpdate, writeConcern: writeConcern)
          .then((confirmMsg) {
            return confirmMsg;
          });
        
        futureList.add(operation);
      })
    .then((_) {
      return Future
        .wait(futureList)
        .then((List confirmMsgList) {
          return confirmMsgList;
        });
    });
  }
  
  /**
   * Saves a single document based on query results.
   */
  Future save(Map document, {WriteConcern writeConcern}) {
    var cursor = collection.save(document, writeConcern: writeConcern);
    return cursor;
  }
  
  /**
   * Saves a list of documents;
   */
  Future saveAll(List<Map> documents, {WriteConcern writeConcern}) {
    var futureList = [];
    
    return Future.forEach(documents, (Map doc) {
      var operation = db
        .collection(collName)
        .save(doc, writeConcern: writeConcern)
        .then((confirmMsg) {
          return confirmMsg;
        });
      
      futureList.add(operation);
    })
    .then((_) {
      return Future
        .wait(futureList)
        .then((List confirmMsgList) {
          return confirmMsgList;
        });
    });
  }
  
  /**
   * Removes a single document based on query results.
   */
  Future remove([SelectorBuilder query, WriteConcern writeConcern]) {
    var cursor = collection.remove(query, writeConcern);
    return cursor;
  }
  
  /**
   * Removes a list of documents based on query results.
   */
  Future removeAll(List<SelectorBuilder> queryList, [WriteConcern writeConcern]) {
    var futureList = [];
    
    return Future.forEach((queryList), (SelectorBuilder query) {
      var operation = db
        .collection(collName)
        .remove(query, writeConcern)
        .then((confirmMsg) {
          return confirmMsg;
        });
      
      futureList.add(operation);
    })
    .then((_) {
      return Future
        .wait(futureList)
        .then((List confirmMsgList) {
          return confirmMsgList;
        });
    });
  }
  
  /**
   * Closes connection to database.
   */
  Future close() {
    return db.close();
  }
  
  /**
   * Convenience version of [find]. Closes connection upon completion.
   */ 
  Future<List<Map>> openDbFind([SelectorBuilder query]) {
    db = new Db('$uri\/${dbName}');
    collection = db.collection(collName);
      
    return db
      .open()
      .then((_) {
        return find(query)
          .then((docList) {
            db.close();
            return docList;
          });           
      });
  }
  
  /**
   * Convenience version of [findOne]. Closes connection upon completion.
   */  
  Future<Map> openDbFindOne([SelectorBuilder query]) {
    db = new Db('$uri\/${dbName}');
    collection = db.collection(collName);
    
    return db
      .open()
      .then((_) {
        return findOne(query)
          .then((doc) {
            db.close();
            return doc;
          });           
      });
  }  
  
  /**
   * Convenience version of [insert]. Closes connection upon completion.
   */
  Future openDbInsert(Map document, {WriteConcern writeConcern}) {
    db = new Db('$uri\/${dbName}');
    collection = db.collection(collName);
    
    return db
      .open()
      .then((_) {
        return insert(document, writeConcern: writeConcern)
          .then((confirmMsg) {
            db.close();
            return confirmMsg;
          });
      });
  }
  
  /**
   * Convenience version of [insertAll]. Closes connection upon completion.
   */
  Future openDbInsertAll(List<Map> documents, {WriteConcern writeConcern}) {
    db = new Db('$uri\/${dbName}');
    collection = db.collection(collName);
      
    return db
      .open()
      .then((_) {
        return insertAll(documents, writeConcern: writeConcern)
          .then((confirmMsg) {
            db.close();
            return confirmMsg;
          });    
      });
  }
  
  /**
   * Convenience version of [update]. Closes connection upon completion.
   */  
  Future openDbUpdate(SelectorBuilder query, Map document, {bool upsert, bool multiUpdate, WriteConcern
    writeConcern}) {
    db = new Db('$uri\/${dbName}');
    collection = db.collection(collName);
    
    return db
      .open()
      .then((_) {
        return update(query, document, upsert: upsert, multiUpdate: multiUpdate, writeConcern: writeConcern)
          .then((confirmMsg) {
            db.close();
            return confirmMsg;
          });
      });
  }
  
  /**
   * Convenience version of [updateAll]. Closes connection upon completion.
   */  
  Future openDbUpdateAll(List<Map<SelectorBuilder, Map>> queryDocList, {bool upsert, bool multiUpdate, WriteConcern
    writeConcern}) {
    db = new Db('$uri\/${dbName}');
    collection = db.collection(collName);
    
    return db
      .open()
      .then((_) {
        return updateAll(queryDocList, multiUpdate: multiUpdate, writeConcern: writeConcern)
          .then((confirmMsg) {
            db.close();
            return confirmMsg;
          });
      });
  }
  
  /**
   * Convenience version of [save]. Closes connection upon completion.
   */  
  Future openDbSave(Map document, {WriteConcern writeConcern}) {
    db = new Db('$uri\/${dbName}');
    collection = db.collection(collName);
      
    return db
      .open()
      .then((_) {
        return save(document, writeConcern: writeConcern)
         .then((confirmMsg) {
           db.close();
           return confirmMsg; 
         });
      });
  } 
  
  /**
   * Convenience version of [saveAll]. Closes connection upon completion.
   */  
  Future openDbSaveAll(List<Map> documents, {WriteConcern writeConcern}) {
    db = new Db('$uri\/${dbName}');
    collection = db.collection(collName);
      
    return db
      .open()
      .then((_) {
        return saveAll(documents, writeConcern: writeConcern)
          .then((confirmMsg) {
            db.close();
            return confirmMsg;
          });  
      });
  }
  
  /**
   * Convenience version of [remove]. Closes connection upon completion.
   */  
  Future openDbRemove([SelectorBuilder query, WriteConcern writeConcern]) {
    db = new Db('$uri\/${dbName}');
    collection = db.collection(collName);
    
    return db
      .open()
      .then((_) {
        return remove(query, writeConcern)
          .then((confirmMsg) {
            db.close();
            return confirmMsg;
          });    
      });
  }
  
  /**
   * Convenience version of [removeAll]. Closes connection upon completion.
   */  
  Future openDbRemoveAll(List<SelectorBuilder> queryList, [WriteConcern writeConcern]) {
    db = new Db('$uri\/${dbName}');
    collection = db.collection(collName);
    
    return db
      .open()
      .then((_) {
        return removeAll(queryList, writeConcern)
          .then((confirmMsg) {
            db.close();
            return confirmMsg;
          });    
      });
  }
}