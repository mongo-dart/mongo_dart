# Mongo-dart - MongoDB driver for Dart programming language

[![Pub](https://img.shields.io/pub/v/mongo_dart.svg)](https://pub.dartlang.org/packages/mongo_dart)
[![Build Status](https://travis-ci.org/mongo-dart/mongo_dart.svg?branch=master)](https://travis-ci.org/mongo-dart/mongo_dart)

Server-side driver library for MongoDb implemented in pure Dart.

## Development release

Please, note that this is a development release, published only to permit testing and suggestions from the users. Do not use in production.  See OP_MSG section

## Basic usage

### Obtaining connection

```dart

  var db = Db("mongodb://localhost:27017/mongo_dart-blog");
  await db.open();
```

or

```dart
  var db = await Db.create("mongodb+srv://<user>:<password>@<host>:<port>/<database-name>?<parameters>");
  await db.open();
```

### Querying

Method `find` returns stream of maps and accept query parameters, usually build by fluent API query builder
provided by [mongo_dart_query](https://github.com/vadimtsushko/mongo_dart_query) as top level getter `where`

```dart

  var coll = db.collection('user');
  await coll.find(where.lt("age", 18)).toList();
  
  //....
  
  await coll
      .find(where.gt("my_field", 995).sortBy('my_field'))
      .forEach((v) => print(v));

  //....
  
  await coll.find(where.sortBy('itemId').skip(300).limit(25)).toList();
  
```

Method `findOne` take the same parameter and returns `Future` of just one map (mongo document)

```dart

  val = await coll.findOne(where.eq("my_field", 17).fields(['str_field','my_field']));
```

Take notice in these samples that unlike mongo shell such parameters as projection (`fields`), `limit` and `skip`
are passed as part of regular query through query builder

### Inserting documents

```dart

  await usersCollection.insertAll([
    {'login': 'jdoe', 'name': 'John Doe', 'email': 'john@doe.com'},
    {'login': 'lsmith', 'name': 'Lucy Smith', 'email': 'lucy@smith.com'}
  ]);
```

### Updating documents

You can update whole document with method `save`

```dart

  var v1 = await coll.findOne({"name": "c"});
  v1["value"] = 31;
  await coll.save(v1);
```

or you can perform field level updates with method `update` and top level getter `modify` for ModifierBuilder fluent API

```dart

  coll.update(where.eq('name', 'Daniel Robinson'), modify.set('age', 31));

```

### Removing documents

```dart

  students.remove(where.id(id));
  /// or, to remove all documents from collection
  students.remove();

```

Simple app on base of [JSON ZIPS dataset](https://media.mongodb.org/zips.json)

```dart
import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  void displayZip(Map zip) {
    print(
        'state: ${zip["state"]}, city: ${zip["city"]}, zip: ${zip["id"]}, population: ${zip["pop"]}');
  }
  var db =
      Db("mongodb://reader:vHm459fU@ds037468.mongolab.com:37468/samlple");
  var zips = db.collection('zip');
  await db.open();
  print('''
******************** Zips for state NY, with population between 14000 and 16000,
******************** reverse ordered by population''');
  await zips
      .find(where
          .eq('state', 'NY')
          .inRange('pop', 14000, 16000)
          .sortBy('pop', descending: true))
      .forEach(displayZip);
  print('\n******************** Find ZIP for code 78829 (BATESVILLE)');
  var batesville = await zips.findOne(where.eq('id', '78829'));
  displayZip(batesville);
  print('******************** Find 10 ZIP closest to BATESVILLE');
  await zips
      .find(where.near('loc', batesville["loc"]).limit(10))
      .forEach(displayZip);
  print('closing db');
  await db.close();
}
```

### Building aggregation queries

```dart
import 'package: mongo_dart/mongo_dart.dart';

main() async {
  final db = Db('mongodb://127.0.0.1/testdb');
  final pipeline = AggregationPipelineBuilder()
    .addStage(
      Match(where.eq('status', 'A').map['\$query']))
    .addStage(
      Group(
        id: Field('cust_id'),
        fields: {
          'total': Sum(Field('amount'))
        }
      )).build();
  final result =
    await DbCollection(db, 'orders')
      .aggregateToStream(pipeline).toList();
  result.forEach(print);
}
```

### Secure connection

You can connect using a secured tls/ssl connection in one of these two ways:

* setting the secure connection parameter to true in db.open()

```dart
    await db.open(secure: true);
```

* adding a query parameter => "tls=true" (or "ssl=true").

```dart
    var db = DB('mongodb://www.example.com:27017/test?tls=true&authSource=admin');
              or
    var db = DB('mongodb://www.example.com:27017/test?ssl=true&authSource=admin');
```

When you use the `mongodb+srv` url schema, the "tls" (or "ssl") parameter is implicitly considered true.

No certificates can be used.

### Atlas (MongoDb cloud service) connection

Atlas requires a tls connection, so now it is possible to connect to this cloud service.
When creating a cluster Atlas shows you three ways of connecting:
Mongo shell, Driver and MongoDb Compass Application.
The connection string is in Seedlist Connection Format (starts with mongodb+srv://).

Take the Url related to the Driver mode and pass it to Db.create().

Please, not that Db.create is an asynchronous constructor, so you have to await for it.

```dart
  var db = await Db.create("mongodb+srv://<user>:<password>@<host>:<port>/<database>?<parameters>");
  await db.open();
```

### OP_MSG

**Only for those using mongodb version 3.6 or later**
**State**: *experimental*

[**Donate** If you need a reliable driver like I do, please help me maintaining this software with a donation. This will allow me to dedicate more time on development, testing and documentation.](https://www.paypal.com/donate?hosted_button_id=YRUNF9YWKX2NW)

Starting from 3.6, a new protocol has been developed form mongodb to exchange data with the server.
We are updating all commands and operation so that we can use the new protocol.
This will be done gradually.
At present we have developed the following operations:

| Command | Status | Legacy alternative | Notes |
| --- | --- | --- | --- |
|   `insertOne`  |  Experimental   |  `insert`   | `insertOne` was already present in the previous release, but some changes in the call have been made    |
| `insertMany` | Experimental | `insert` | Allows to insert many documents in one commnand. It is subject to the max number of documents per message limit (at present <4.4> 100,000)|
| `modernFind` | Experimental | `legacyFind` | The old method `find` now is simply a wrapper. If you are running mongoDb 3.6 or later, `modernFind` is called, otherwise `legacyFind` |
| `modernAggregate` | Experimental |  `legacyAggregateToStream` | The old method `aggregateToStream` now is simply a wrapper. If you are running mongoDb 3.6 or later, `modernAggregate` is called, otherwise `legacyAggregateToStream`|
| `modernAggregateCursor` | Experimental | - | This method has no corresponding legacy one, as it returns a cursor and not a Map like the legacy `aggregate`|
| - | Production  | `aggregate` | The legacy method `aggregate` has no corresponding "moderm" method. It returns a Map. Is it used? |
| `watch` | Experimental | - | This method has no corresponding legacy methods. Allows to monitor changes to a collection |
| `watchCursor` | Experimental | - |This method has no corresponding legacy methods. Like `watch`, but resturns a cursor instead of a stream. Normally you will only need `watch` |

Something on the bulk write side has been done too:
There is the new collection helper method bulkWrite. The syntax is quite similar to that of the shell:
`collection.bulkWrite([{'insertOne': {'document': { "_id" : 1, "char" : "Brisbane", "class" : "monk", "lvl" : 4 }}}]);`
Like the in the shell you can define the `insertOne`, `deleteOne` and `deleteMany` operations. `updateOne`, `updateMany` and `replaceOne` must be still developed.
In addition to the shell operation, you can use also an `insertMany` operation, with the following sybtax:
`collection.bulkWrite([{'insertMany': {'documents': [{ "_id" : 1, "char" : "Brisbane", "class" : "monk", "lvl" : 4 }]}}]);`
Unlike the insertMany helper, this bulk operation does not suffer of the max number of documents per message limitation.

Aside to these changes we have also to mention the new Decimal128 type management (that is backed by the Rational class).
This is inherited from enhancements in the BSON package

Last but not least, some commands:
|Command| Status | Legacy alternative | Notes |
|--- | --- | --- | --- |
| `createIndex` | Production | `db.createIndex` | This was needed because the legacy method didn't work any more starting from release 4.0 |
| `createCollection` | Experimental | - | Explicitly creates a collection. Useful if you want to create a capped collection or assign a collation to the collection.|
| `createView` | Experimental | - | Creates a view |
| `getParameterCommand` | Experimental | - | Allows to get a specific server parameter |
| `getAllParametersCommand` | Experimental | - | Returns all config parameters |
| `killCursorCommand` | Experimental | `MongoKillCursorMessage` | Used internally to close an unexhausted cursor.|
| `getMoreCommand` | Experimental | `MongoGetMoreMessage` | Used internally to read a new batch of data from the server |
| `getLastErrorCommand` | Experimental | `DbCommand.createGetLastErrorCommand` | Used internally to return the status of the previous operation. It is no more needed with the modern operations, but, for compatibility reasons, it can be used still. |
| `serverStatus` | Experimental | `serverStatus` | The method was already present, but it has been improved giving the possiblity to return a class with all the values instead of a map |

### See also

* [API Doc](https://pub.dev/documentation/mongo_dart/latest/)

* [Status](https://github.com/mongo-dart/mongo_dart/projects/1)

* [Recent change notes](https://github.com/mongo-dart/mongo_dart/blob/master/CHANGELOG.md)

* Additional [examples](https://github.com/mongo-dart/mongo_dart/tree/master/example) and [tests](https://github.com/mongo-dart/mongo_dart/tree/master/test)
