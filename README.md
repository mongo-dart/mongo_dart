# Mongo-dart - MongoDB driver for Dart programming language

<!-- [![Pub](https://img.shields.io/pub/v/mongo_dart.svg)](https://pub.dartlang.org/packages/mongo_dart)
[![Build Status](https://travis-ci.org/mongo-dart/mongo_dart.svg?branch=main)](https://travis-ci.org/mongo-dart/mongo_dart)
-->

Server-side driver library for MongoDb implemented in pure Dart. Server side means all packages using dart:io, dart:html are not accepted.

**NOTE**
This is a fork that uses univesal_io in place of dart:io, in order to be used in flutter web applications.

**NOTE**
Starting from release 6.0 of MongDb the old messages structure has been removed (almost completely). This means that some commands cannot be annymore executed. As per compatibility reasons with (very) old releases we are returning in some wrappers (like `insert` method) the result of this commands (in detail `getLastError` command), to let your programs work you should use instead the OP_MSG version. In general this methods are prefixed with `modern`, but this is not the case for all.
For example, instead of `insert`, you should use `insertOne`, and instead of `update` you should use `updateOne` or `updateMany`.

## Apis

Apis normally are created to behave in the most similar way to the mongo shell.
Obviously not all and not necessarily in the same way, but at least the best possible way of performing a certain operation.
Naming convention also, as far as possible, is maintained equal to the one of the shell.
For compatibility with previous versions, apis for a certain method (for example `find`) normally foresee two versions:

- legacy (example `legacyFind`)
- modern (example `modernFind`)

So the method `find` acts as a wrapper for the two methods above.
The difference is historical, "legacy" methods are intended to be used with MongoDb versions prior to 3.6, "modern" method for the more recent versions. The wrapper automatically will call the correct method, based on MongoDb version, but the interface normally resemble the "legacy" one, so, if you want to use the more recent features, you have to use the "modern" versions.

At present most of crud operations and commands have a "modern" version, but the porting is not yet complete.

## Contribution

If you can contribute to the develpment of this package, your help is welcome!

[**Donate** If you need a reliable driver like I do, please help me maintaining this software with a donation. This will allow me to dedicate more time on development, testing and documentation.](https://www.paypal.com/donate?hosted_button_id=YRUNF9YWKX2NW)

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

#### find

Method `find` returns a stream of maps and accept query parameters, usually build by fluent API query builder
provided by [mongo_dart_query](https://github.com/mongo-dart/mongo_dart_query.git) as top level getter `where`

```dart
  var coll = db.collection('find');
  // Fluent way
  await collection.find(where.eq('name', 'Tom').gt('rating', 10)).toList();
  // or Standard way
  await collection.find({'name': 'Tom', 'rating': {r'$gt': 10}}).toList();
```

[Example for fluent ....](https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/find_fluent.dart) - [Example for standard ....](https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/find.dart)

```dart
  await coll
      .find(where.gt("my_field", 995).sortBy('my_field'))
      .forEach((v) => print(v));

  //....
  
  await coll.find(where.sortBy('itemId').skip(300).limit(25)).toList();
  
```

Take notice in these samples that unlike mongo shell such parameters as projection (`fields`), `limit` and `skip`
are passed as part of regular query through query builder.
If you want to pass them separately, you have to use the `modernFind` method.

#### findOne

Method `findOne` take the same parameter and returns `Future` of just one map (mongo document) or null if not found

```dart
  val = await coll.findOne(where.eq("my_field", 17).fields(['str_field','my_field']));
```

[Example....](https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/find_one.dart)

Take notice in these samples that unlike mongo shell such parameters as projection (`fields`) and `skip`
are passed as part of regular query through query builder.
If you want to pass them separately, you have to use the `modernFindOne` method.

### Inserting documents

#### insertMany

Use `insertMany` to insert some documents if you have mongoDb ver 3.6 or greater

```dart
  await usersCollection.insertMany([
    {'login': 'jdoe', 'name': 'John Doe', 'email': 'john@doe.com'},
    {'login': 'lsmith', 'name': 'Lucy Smith', 'email': 'lucy@smith.com'}
  ]);
```

([Example....](https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/insert_many.dart))

or `insertAll` otherwise

```dart
  await usersCollection.insertAll([
    {'login': 'jdoe', 'name': 'John Doe', 'email': 'john@doe.com'},
    {'login': 'lsmith', 'name': 'Lucy Smith', 'email': 'lucy@smith.com'}
  ]);
```

#### insertOne

Use `insertOne` to insert only one documents if you have mongoDb ver 3.6 or greater

```dart
  await usersCollection.insertOne({'login': 'jdoe', 'name': 'John Doe', 'email': 'john@doe.com'});
```

([Example....](https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/insert_one.dart))

or `insert` otherwise

```dart
  await usersCollection.insert({'login': 'jdoe', 'name': 'John Doe', 'email': 'john@doe.com'});
```

### Updating documents

#### replaceOne

You can update the whole document with method `replaceOne` if you have mongoDb ver 3.6 or greater

```dart
  var v1 = await coll.findOne({"name": "c"});
  v1["value"] = 31;
  await coll.replaceOne({"name": "c"}, v1);
```

([Example....](https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/replace_one.dart))

or `save` otherwise

```dart
  var v1 = await coll.findOne({"name": "c"});
  v1["value"] = 31;
  await coll.save(v1);
```

#### updateOne

You can perform field level updates on one document only with method `updateOne` and top level getter `modify` for ModifierBuilder fluent API (mongoDb ver 3.6 or greater).

```dart
  coll.updateOne(where.eq('name', 'Daniel Robinson'), modify.set('age', 31));
```

([Example....](https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/update_one.dart))

or `update` with MongoDb versions prior to 3.6

```dart
  coll.update(where.eq('name', 'Daniel Robinson'), modify.set('age', 31));
```

#### updateMany

You can perform field level updates on multiple documents only with method `updateMany` and top level getter `modify` for ModifierBuilder fluent API (mongoDb ver 3.6 or greater).

```dart
  coll.updateMany(where.eq('name', 'Daniel Robinson'), modify.set('age', 31));
```

([Example....](https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/update_many.dart))

or `update` and multiUpdate parameter with MongoDb versions prior to 3.6

```dart
  coll.update(where.eq('name', 'Daniel Robinson'), modify.set('age', 31), multiUpdate: true);
```

### Removing documents

#### deleteOne

You can delete one document only with method `deleteOne` if you have mongoDb ver 3.6 or greater

```dart
  await coll.deleteOne({"name": "Karl"});
```

([Example....](https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/delete_one.dart))

no specific method otherwise. You could use `remove` using a filter that selected only one document (best on "_id" field)

```dart
  await coll.remove({'_id': 25});
```

#### deleteMany

You can delete many documents in one time with method `deleteMany` if you have mongoDb ver 3.6 or greater

```dart
  await coll.deleteMany({"name": "Karl"});
```

([Example....](https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/delete_many.dart))

or `remove` with MongoDb versions prior to 3.6

```dart
  students.remove(where.eq('name, 'Karl));
```

## Simple app

[Simple app](https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/generic/zips.dart) based on [JSON ZIPS dataset](https://media.mongodb.org/zips.json)

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

- setting the secure connection parameter to true in db.open()

```dart
    await db.open(secure: true);
```

- adding a query parameter => "tls=true" (or "ssl=true").

```dart
    var db = DB('mongodb://www.example.com:27017/test?tls=true&authSource=admin');
              or
    var db = DB('mongodb://www.example.com:27017/test?ssl=true&authSource=admin');
```

When you use the `mongodb+srv` url schema, the "tls" (or "ssl") parameter is implicitly considered true.

You can also use certificates for tls handshake [see this tutorial][19] for more info.

### Authentication

The driver supports three authentication methods:

- SCRAM_SHA_1
- SCRAM_SHA_256
- X509. See [here][20] for more details.

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

**Only for those** using mongodb version 3.6 or later

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
| `watchCursor` | Tested | - |This method has no corresponding legacy methods. Like `watch`, but returns a cursor instead of a stream. Normally you will only need `watch` |

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
| `createCollection` | Tested | - | Explicitly creates a collection. Useful if you want to create a capped collection or assign a collation to the collection.|
| `createView` | Tested | - | Creates a view |
| `getParameterCommand` | Tested | - | Allows to get a specific server parameter |
| `getAllParametersCommand` | Tested | - | Returns all config parameters |
| `killCursorCommand` | Tested | `MongoKillCursorMessage` | Used internally to close an unexhausted cursor.|
| `getMoreCommand` | Tested | `MongoGetMoreMessage` | Used internally to read a new batch of data from the server |
| `getLastErrorCommand` | Tested | `DbCommand.createGetLastErrorCommand` | Used internally to return the status of the previous operation. It is no more needed with the modern operations, but, for compatibility reasons, it can be used still. |
| `serverStatus` | Tested | `serverStatus` | The method was already present, but it has been improved giving the possiblity to return a class with all the values instead of a map |

### See also

- [API Doc](https://pub.dev/documentation/mongo_dart/latest/)

- [Status](https://github.com/mongo-dart/mongo_dart/projects/1)

- [Recent change notes](https://github.com/mongo-dart/mongo_dart/blob/main/CHANGELOG.md)

- Additional [examples](https://github.com/mongo-dart/mongo_dart/tree/main/example) and [tests](https://github.com/mongo-dart/mongo_dart/tree/main/test)

[1]: https://github.com/mongo-dart/mongo_dart/blob/main/doc/manual/crud/delete.md#deleteOne
[2]: https://github.com/mongo-dart/mongo_dart/blob/main/doc/manual/crud/delete.md#deleteMany
[3]: https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/delete_one.dart
[4]: https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/delete_one_collation.dart "With collation"
[5]: https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/delete_many.dart
[6]: https://github.com/mongo-dart/mongo_dart/blob/main/doc/manual/crud/update.md#updateOne
[7]: https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/update_one.dart
[8]: https://github.com/mongo-dart/mongo_dart/blob/main/doc/manual/crud/update.md#updateMany
[9]: https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/crud/update_many.dart
[10]: https://github.com/mongo-dart/mongo_dart/blob/main/doc/manual/crud/update.md#modernUpdate
[11]: https://github.com/mongo-dart/mongo_dart/blob/main/doc/manual/aggregate/watch.md
[12]: https://github.com/mongo-dart/mongo_dart/blob/main/doc/manual/bulk/bulk.md
[13]: https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/bulk/ordered_collection_helper.dart
[14]: https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/bulk/unordered_collection_helper.dart
[15]: https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/bulk/ordered_bulk.dart
[16]: https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/bulk/unordered_bulk.dart
[17]: https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/watch/watch_on_collection.dart
[18]: https://github.com/mongo-dart/mongo_dart/blob/main/example/manual/watch/watch_on_collection_insert.dart
[19]:  https://github.com/mongo-dart/mongo_dart/blob/main/doc/manual/connection/tls_connection_no_auth_client_certificate.md
[20]: https://github.com/mongo-dart/mongo_dart/blob/main/doc/manual/connection/x509_authentication.md
