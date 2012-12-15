#Recent change notes

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