#mongo_dart - A MongoDB driver for the Dart programming language.

[![Build Status](https://drone.io/github.com/vadimtsushko/mongo_dart/status.png)](https://drone.io/github.com/vadimtsushko/mongo_dart/latest)

Mongo Dart (mongo_dart) is a client library and driver for connecting to MongoDB instances. It is written purely in Dart and thus makes heavy use of it's asynchronous facilities.

By using the [MongoClient] you can easily perform common CRUD operations.

```dart 
var usaDb1 = new MongoClient('accounts', 'A-E');

usaDb1
  .openDb()
  .then((_) {
    db
      .findOne(where.match('customerName' : 'Julie'))
      .then((doc) {
        getAccountInfo(doc);
        db.close();
      });
  });
```
Every CRUD operation has a convenience version that will automatically close the connection to database after completion.

```dart
var mongoQuery = where.gte('balance' : 100000).limit(500)

db
  .openDbFind(mongoQuery)
  .then((docList) {
    for (Map doc in docList) {
      primerAccountRequest(doc['customerID']);
    }
  });
  .
```
Mongo Client also includes methods to help ease operations on a collection.

```dart 
DateTime currentTime = new DateTime.now().toUtc().toLocal();
var docList = [
  {'withdrawDate' :  currentTime},
  {'lastLogOut' :  currentTime},
];

db
  .openDbInsertAll(docList, writeConcern: WriteConcern.ACKNOWLEDGED)
  .then((confirmMsg) {
    logIt(confirmMsg);
  });
```

###Other Documentation:

- [API Doc](http://www.dartdocs.org/documentation/mongo_dart/0.1.39)

- [Feature check list](https://github.com/vadimtsushko/mongo_dart/blob/master/doc/feature_checklist.md)

- [Recent change notes](https://github.com/vadimtsushko/mongo_dart/blob/master/changelog.md)

- Additional [examples](https://github.com/vadimtsushko/mongo_dart/tree/master/example) and [tests](https://github.com/vadimtsushko/mongo_dart/tree/master/test)

- For more structured approach to communication with MongoDB: [Objectory](https://github.com/vadimtsushko/objectory)
 
###License
(The MIT License)

Copyright (c) 2012 Vadim Tsushko (vadimtsushko@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
