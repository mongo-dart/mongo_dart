import 'dart:async';

import 'package:mongo_dart/mongo_dart.dart';

/*
 * Tests all functions within MongoClient class. Passes if all checks return a non-null value.
 * Removes test database after completion.
 */

void main () {
  MongoClient someDb = new MongoClient('bookstore', 'bookshelf');
  bool canInsert = false;
  bool canInsertAll = false;
  bool canFindOne = false;
  bool canFind = false;
  bool canUpdate = false;
  bool canUpdateAll = false;
  bool canSave = false;
  bool canSaveAll = false;
  bool canRemove = false;
  bool canRemoveAll = false;
  
  //Insert test
  var starter = someDb
    .openDbInsert({'_id' : '1008', 'Practical Living' : 9.99})
    .then((confirmMsg) {
      if (confirmMsg != null ) {
        print('Insert successful\n');
        canInsert = true;
        return confirmMsg;
      } 
  })
  .then((_) {
    //InsertAll test
    return someDb
      .openDbInsertAll([{'_id': '1009', 'Vampire\'s Diary' : 19.99}, {'Understanding Fortran' : 11.99}])
      .then((confirmMsg) {
        if (confirmMsg != null) {
          print('InsertAll successful\n');
          canInsertAll = true;
          return confirmMsg;
        } 
      });
  })
  .then((_) {
    //FindOne test
   return someDb
      .openDbFindOne(where.eq('_id', '1008'))
      .then((doc) {
        if (doc != null) {
          print('FindOne successful\n');
          canFindOne = true;
          return doc;
        } 
      });
  })
  .then((_) {
    //Find test
    return someDb
      .openDbFind(where.eq('Practical Living', 9.99))
      .then((docList) {
        if (docList != null) {
          print('Find successful\n');
          canFind = true;
          return docList;
        } 
      });
  })
  .then((_) {
    //Update test
    return someDb
      .openDbUpdate(where.eq('Practical Living', 9.99), {'Practical Living' : 23.99})
      .then((confirmMsg) {
        if (confirmMsg != null ) {
          print('Update successful\n');
          canUpdate = true;
          return confirmMsg;
        } 
      });
  })
  .then((_) {
    //UpdateAll test
    var query1 = where.eq('Practical Living', 23.99);
    var query2 = where.eq('_id', '1009');
    var doc1 = {'Practical Living' : 15.99};
    var doc2 = {'Vampire\'s Diary' : 12.99};
    
    var queryDocList = [
      {query1 : doc1},
      {query2 : doc2},
    ];
    
    return someDb
      .openDbUpdateAll(queryDocList)
      .then((confirmMsg) {
        if (confirmMsg != null) {
          print('UpdateAll successful\n');
          canSaveAll = true;
          return confirmMsg;
        }  
      });
  })
  .then((_) {
    //Save test
    return someDb
      .openDbSave({'Outernet' : 8.99})
      .then((confirmMsg) {
        if (confirmMsg != null ) {
          print('Save successful\n');
          canSave = true;
          return confirmMsg;
        }  
      });
  })
  .then((_) {
    //SaveAll test
    var documents = [
      {'_id' : '1008', 'Practical Living' : 15.99},
      {'_id': '1009', 'Vampire\'s Diary' : 0.99},
    ];
    
    return someDb
      .openDbSaveAll(documents)
      .then((confirmMsg) {
        if (confirmMsg != null) {
          print('SaveAll successful\n');
          canSaveAll = true;
          return confirmMsg;
        }  
      });
  })
  .then((_) {
    //Remove test
    return someDb
      .openDbRemove(where.eq('Practical Living', 15.99))
      .then((confirmMsg) {
        if (confirmMsg != null) {
          print('Remove successful\n');
          canRemove = true;
          return confirmMsg;
        }  
      });
  })
  .then((_) {
    //RemoveAll test
    var queryList = [
      where.eq('Outernet', 8.99), where.eq('Vampire\'s Diary', 0.99), 
      where.eq('Understanding Fortran', 11.99)
    ];
    
    return someDb
      .openDbRemoveAll(queryList)
      .then((List msgList) {
        if (msgList != null) {
          print('RemoveAll successful\n');
          canRemoveAll = true;
          return msgList;
        }  
      });
  })
  .then((_) {
    //Reopens and drops test db
    someDb
      .openDb()
      .then((_) => someDb.db.drop())
      .then((_) {
        //Pass Check
        if (canInsert && canInsert && canFindOne && canFind && canUpdate && canSaveAll &&
            canSave && canRemove && canRemoveAll) {
          print('PASSED: All tests have return a non-null value!');
          
          return true;
        } else {
          print('FAILURE - Please review output below:\n');
          print('Insert: $canInsert\n'
           'InsertAll: $canInsertAll\n'
           'FindOne: $canFindOne\n'
           'Find: $canFind\n'
           'Update: $canUpdate\n'
           'UpdateAll: $canUpdateAll\n'
           'CanSave: $canSave\n'
           'CanSaveAll: $canSaveAll\n'
           'CanRemove: $canRemove\n'
           'CanRemoveAll: $canRemoveAll\n'
          );
          
          return false;
        } 
      });
  });
}

