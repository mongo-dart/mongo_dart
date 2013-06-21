#Recent change notes

###0.1.22

- [Paul Evans] (https://github.com/PaulECoyote) added raw aggregate operation 

###0.1.21

- [Paul Evans] (https://github.com/PaulECoyote) added distinct operation 


###0.1.20

- Upgrade for Dart SDK version 0.5.13.1_r23552


###0.1.19

- Query API supports logical AND and OR operators.

###0.1.18

- Bugfix to [fields() issue ](https://github.com/vadimtsushko/mongo_dart/issues/26). Fields clause in find(), findOne() methods did not work.
Relevant test and sample (in example/query.dart) added

###0.1.17

- Update for changed SelectorBuilder 

###0.1.15

- mongo_dart_query published separately and added as dependency to mongo_dart. Unified SelectorBuilder will be used by mongo_dart and objectory.  

###0.1.14

- Bson library published separately and added as dependency to mongo_dart  


###0.1.13

- Upgrade in Bson for changed implementation of dart:typeddata in Dart SDK version 0.5.0.1_r21823.  

###0.1.12

- Upgrade for M4.  

###0.1.10 

- Switch from dart:scalarlist to dart:typeddata. Logging updated to new API.

###0.1.9 

- Bug fix on [Issue 18] (https://github.com/vadimtsushko/mongo_dart/issues/18) about db.ensureIndex

###0.1.8

- Bug fix for unitialized BsonPlatform

###0.1.7

- Bug fix for MongoMessage header curruption

###0.1.6

- Support for dart SDK version 0.4.2.5_r20193

###0.1.4

- Support for Dart Editor version 0.4.1_r19425

###0.1.3

- GridFS refactored, now works on all old and added tests.

###0.1.2

- GridFS still broken, but in this version there is no malformed types from previous dart:io version 

###0.1.1

- Support of dart:io version 2. (Stream-based). 
- [WriteConcern] (http://docs.mongodb.org/manual/core/write-operations/#write-concern) introduced. Db.open method has writeConcern param, as individual modifying operations. Default writeConcern = WriteConcern.AKNOWLEDGED
- writeConcern parameter replaced safeMode parameter on modifying operations
- GridFS not yet ported to dart:io version 2.

###0.0.14

- Fixed bug in limit functionality. Corresponding test added.

###0.0.12

- M3 ready. Run on version 0.3.1.1_r17328

###0.0.10

- New syntax cleanUp. Next revisions will be published on pub.dartlangl.org. No more need to use git dependency for dependend application. 

###0.0.9

- Ted Sander joined project and added initial support of GridFS functionality

###0.0.8

- Fixed bux in database_tests.dart (Process did not ends cleanly)
- Sdk package dependencies moved to pub.dartlang.org 

###0.0.7

- new syntax changes
- Selector API changed
- modifier_builder added

###0.0.6

- Repairing incomplete commit v0.0.5 

###0.0.5

- DbCollection's update and insert methods got optional *safeMode* parameter
- $err field set in MongoDB result object raises Error in mongo_dart
- Db got createIndex and ensureIndex methods
- Feature checklist added.

###0.0.4

- code updates for SDK r14458

###0.0.3

- Changes reflecting dart lib changes - methods to getters, such as String.charCodes(), Map.getKeys() and so on
- New rules for optional function parameters applied
- Tests reworked. Got rid of asyncTest. Use expectAsync1 within future chain() and then() methods.