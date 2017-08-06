#Recent change notes

### 0.4.0
- Changed the signature of `DbCollection.remove`; its `selector` parameter is now required,
while `writeConcern` is now a named optional parameter.

```dart
Future remove(selector, {WriteConcern writeConcern});
```

Resolves [#73](https://github.com/mongo-dart/mongo_dart/issues/73).

###0.3.0

- Strong mode compliance. Preparing for Dart 2.0

###0.2.8

- Fix bad type in _Connection class

###0.2.7

- Minor changes, commented out code removed
- Big chunk of tests was commented out in 0.2.6 by error. All tests restored. 

###0.2.6

- update for new sdk (with 1.17.0 [MongoMessageHandler] was broken in checked mode)
- upgrade to current version of `crypto` package, and it's new (Converter based) API 

###0.2.5+1

- Fixed markdown for pub.

###0.2.5

- Moved mongo_dart project to a new organization on [GitHub](https://github.com/mongo-dart/mongo_dart).
- Authentication schemes now use Secure Random coming from `dart:math` since 1.14. ** Note that this version now
required SDK version >= 1.14 because of this **
- Added sort by text score to the query builders.

###0.2.5-beta

- SCRAM-SHA1 authentication scheme added by Joel Trottier-Hebert. Random string (salt) is generated
 with standard dart Random, which is not cryptographically strong for now, hence beta marker on version.  
 Secure Random is due in the next version of SDK, so that would be improved soon.
- SCRAM-SHA1 scheme used as a default while driver is connected to mongodb 3.0, MONGODB_CR used otherwise. 
 `authMechanism` connection string option can be used to override these defaults.
- `authSource` connection string option added See: https://github.com/vadimtsushko/mongo_dart/issues/72
- Many refactorings in tests and code with async/await done by Joel Trottier-Hebert
- Dependency on `logging` package loosen to >=0.9.1 <0.12.0  

###0.2.4

- Small bump up in dependencies

###0.2.3

- Swithed to travis from drone.io
- Can use null-aware operators in example (blog)

###0.2.2

- Loosening parameter type in CursorStream in accordance with sdk 1.13.0
- README update with basic usage

###0.2.1

  - Fix issue [71](https://github.com/vadimtsushko/mongo_dart/issues/71) - Logger allocates lot of strings


###0.2.0

- Breaking change: DbCollection `find` method now returns Stream<Map> instead of Cursor. 
  Cursor have had compatible with Stream<Map> `toList` and `forEach` quite some time already, so in case you used these methods only,
  you should be covered. On the other hand if you used `find().stream` to get a stream it is not valid anymore. In that case you
  should change your code to plain `find()`
- Breaking change: This version use upgraded version of `bson`. `ObjectId.toJson` now converts `ObjectId` to simple hex string representation.
  Earlier it was something like `ObjectId('a29d3ae24...aa')` New behaviour would be more useful when you serialize `bson` map to json be default
  conversion. With new behaviour serialized ObjectId value could be passed to `ObjecdId.parse` method.
  But if your code currently depends on old behaviour (if you now use something like `id.substring(10, 34)` to get hex part of the 
  string representation, you should change your code.

###0.1.47

- compatibility with MongoDB 3.0 and WiredTiger. New `db.getCollectionNames()`,
 `db.getCollectionInfos()`, `collection.getIndexes()` methods, backward compatible with earlier versions of MongoDb.
- `collectionsInfoCursor`, `listCollections`, `indexInformation` methods of Db deprecated
- use `test` instead of `unittest` package
- add code coverage metrix with coveralls.io


###0.1.46

- Save method use `upsert` flag in accordance with [mongodb docs](http://docs.mongodb.org/manual/reference/method/db.collection.save/)

###0.1.45

- Remove validation for index keys.

###0.1.44

- Tailable cursor support added by sestegra. See tailable_cursor.dart in example directory.
- Preliminary support for streaming in Aggregate framerork. Added method `aggregateToStream`
- Added getBuildInfo command

###0.1.43

- Additional checks and descriptive error message against opening db in opening state, additional tests

###0.1.42

- Additional checks and descriptive error message against querying closed db

###0.1.41

- Bugfix for [Issue 51] (https://github.com/vadimtsushko/mongo_dart/issues/51) Can't reopen a closed database
- API docs redirected to dartdocs.org [Issue 48] (https://github.com/vadimtsushko/mongo_dart/issues/48)

###0.1.40

- Better error handling when a connection with the database is lost. Thanks to [luizmineo](https://github.com/luizmineo) [PR 50](https://github.com/vadimtsushko/mongo_dart/pull/50). 
- `Future(List<String>) listCollections()` helper added to Db 
- `Future(List<String>) listDatabases()` helper added to Db 

###0.1.39

- Better error handling. Bugfix for [issue 49](https://github.com/vadimtsushko/mongo_dart/issues/49)

###0.1.38

- Initial support for replica set added by [sestegra](https://github.com/sestegra)

###0.1.37

- Change log made compatible with pub site preferences, thanks to Andreas Olund.
- API docs generation set up as hop task.

###0.1.36

- Optimization in networking protocol: insert, update and remove commands now sent in one packet with subsequent 
getLastError(). See https://github.com/vadimtsushko/mongo_dart/issues/41 
Speedup on operations with default WriteConcern:ACKNOWLEDGED vary from 50% and more. 
Many thanks to https://github.com/tomaskulich

###0.1.35

- Ready for Dart 1.0

###0.1.34

- adding multiupdate support

###0.1.33

- Upgrade for Dart SDK version 0.8.10.3_r29803

###0.1.3

- Meta lib removed.
 
###0.1.31

- Upgrade for braking changes in dart:async (StreamEventTransformed removed from API). 
Ready for Dart SDK version 0.8.5.1_r28990

###0.1.30

- Version contraints removed from pubspec

###0.1.29

- Merge pull request from analogic. Added Future to save and removed unnecessary completers

###0.1.28

- Bugfix for count() method

###0.1.27 

- New sample added. Readme rewritten.

###0.1.26

- Network data packets to MongoDb messages conversion refactored.

###0.1.25

- each() method is deprecated in favor of foEach(), so Cursor have more stream-like interface. 
- stream getter added to Cursor. After deprecation period find() will return Stream<Map> instead of Cursor  

###0.1.24

- Added support for modifier builder for field level updates. See example/update.dart and testFieldLevelUpdateSimple

###0.1.23

- Updgrate for Dart SDK version 0.6.3.3_r24898 (? operator removed)

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
