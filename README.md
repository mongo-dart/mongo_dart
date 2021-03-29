# Mongo-dart - MongoDB driver for Dart programming language

Server-side driver library for MongoDb implemented in pure Dart.

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

You can also use certificates for tls handshake [see this tutorial][19] for more info.

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
| :---: | --- | :---: | --- |
| - | Not developed | `Save` | This method has been deprecated. |
|   `insertOne`  |  Tested   |  `legacyInsert`   | The old method `insert` is a wrapper that calls `insertOne` if you are running MongoDb 3.6 or later, otherwise `legacyInsert`. |
| `insertMany` | Tested | `legacyInsertAll` | Allows to insert many documents in one command. It is subject to the max number of documents per message limit (at present <4.4> 100,000).The old method `insertAll` is a wrapper that calls `insertMany` if you are running MongoDb 3.6 or later, otherwise `legacyInsertAll`. |
| [deleteOne][1] |  Tested   |  -  | Allows to delete one document. [Example][3] [Example 2][4] |
| [deleteMany][2] | Tested | `legacyRemove` | The old method `remove` is a wrapper that calls `deleteMany` if you are running MongoDb 3.6 or later, otherwise `legacyRemove`. Allows to delete many documents in one commnand. [Example][5] |
| [updateOne][6] | Tested | - | Allows to update one document [Example][7] |
| [updateMany][8] | Tested | - | Allows to update many documents in one command. [Example][9] |
| [modernUpdate][10] | Tested | `legacyUpdate` | The old method `update` now is only a wrapper. If you are running MongoDb 3.6 or later, `modernUpdate` is called, otherwise `legacyUpdate` |
| - | To be developed yet | `count` | |
| `modernDistinct` | Experimental | `legacyDistinct` | The old method `distinct` now is only a wrapper. If you are running MongoDb 3.6 or later, `modernDistinct` is called, otherwise `legacyDistinct` |
| `modernFind` | Tested | `legacyFind` | The old method `find` now is simply a wrapper. If you are running MongoDb 3.6 or later, `modernFind` is called, otherwise `legacyFind` |
| `modernFindOne` | Tested | `legacyFindOne` | The old method `findOne` now is simply a wrapper. If you are running MongoDb 3.6 or later, `modernFindOne` is called, otherwise `legacyFindOne` |
| `modernFindAndModify`| Tested | `legacyFindAndModify`| The old method `findandModify` now is simply a wrapper. If you are running MongoDb 3.6 or later, `modernFindAndModify` is called, otherwise `legacyFindAndModify` |
| `modernAggregate` | Tested |  `legacyAggregateToStream` | The old method `aggregateToStream` now is simply a wrapper. If you are running mongoDb 3.6 or later, `modernAggregate` is called, otherwise `legacyAggregateToStream`|
| `modernAggregateCursor` | Tested | - | This method has no corresponding legacy one, as it returns a cursor and not a Map like the legacy `aggregate`|
| - | Production  | `aggregate` | The legacy method `aggregate` has no corresponding "modern" method. It returns a Map. Is it used? |
| [watch][11] | Tested | - | This method has no corresponding legacy methods. Allows to monitor changes in a collection. Examples: [watch selecting records][17] - [watch all insert operations][18] |
| `watchCursor` | Experimental | - |This method has no corresponding legacy methods. Like `watch`, but returns a cursor instead of a stream. Normally you will only need `watch` |

There is the new collection helper method [bulkWrite][12]. The syntax is quite similar to that of the shell:
`collection.bulkWrite([{'insertOne': {'document': { "_id" : 1, "char" : "Brisbane", "class" : "monk", "lvl" : 4 }}}]);`
Like the one in the shell you can define the `insertOne`, `deleteOne`, `deleteMany`, `updateOne`, `updateMany` and `replaceOne`.
In addition to the shell operation, you can use also an `insertMany` operation, with the following syntax:
`collection.bulkWrite([{'insertMany': {'documents': [{ "_id" : 1, "char" : "Brisbane", "class" : "monk", "lvl" : 4 }]}}]);`
Unlike the insertMany helper, this bulk operation does not suffer of the max number of documents per message limitation.
You can also use directly the Bulk Object, if you prefer. Some examples:
[ordered Collection helper][13], [unordered collection helper][14], [ordered Bulk class][15] and [unordered Bulk Class][16]

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

[1]: doc/manual/crud/delete.md#deleteOne
[2]: doc/manual/crud/delete.md#deleteMany
[3]: example/manual/crud/delete_one.dart
[4]: example/manual/crud/delete_one_collation.dart "With collation"
[5]: example/manual/crud/delete_many.dart
[6]: doc/manual/crud/update.md#updateOne
[7]: example/manual/crud/update_one.dart
[8]: doc/manual/crud/update.md#updateMany
[9]: example/manual/crud/update_many.dart
[10]: doc/manual/crud/update.md#modernUpdate
[11]: doc/manual/aggregate/watch.md
[12]: doc/manual/bulk/bulk.md
[13]: example/manual/bulk/ordered_collection_helper.dart
[14]: example/manual/bulk/unordered_collection_helper.dart
[15]: example/manual/bulk/ordered_bulk.dart
[16]: example/manual/bulk/unordered_bulk.dart
[17]: example/manual/watch/watch_on_collection.dart
[18]: example/manual/watch/watch_on_collection_insert.dart
[19]: doc/manual/connection/simple_connection_no_auth.md
