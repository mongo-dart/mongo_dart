# Watch

Watch allows to trigger changes on a collection. MongoDb foresee also the possibility of tracking changes on Database and collection changes (like drop for instance), but the actual version of this driver only notifies on data changes (insert, update and delete).

## Availability

`DbCollection.watch()` is available for replica set and sharded cluster deployments :

- For a replica set, you can issue `DbCollection.watch()` on any data-bearing member.
- For a sharded cluster, you must issue `DbCollection.watch()` on a mongos instance.

`DbCollection.watch()` only notifies on data changes that have persisted to a majority of data-bearing members.
The change stream cursor remains open until one of the following occurs:

- The cursor is explicitly closed.
- An invalidate event occurs; for example, a collection drop or rename.
- The connection to the MongoDB deployment is closed.
- If the deployment is a sharded cluster, a shard removal may cause an open change stream cursor to close, and the closed change stream cursor may not be fully resumable.

### Resumability

Unlike other MongoDB drivers, mongo_dart does not automatically attempt to resume a change stream cursor after an error. The MongoDB drivers make one attempt to automatically resume a change stream cursor after certain errors.

### Storage Engine

You can only use `DbCollection.watch()` with the Wired Tiger storage engine.

### Read Concern majority Support

Starting in MongoDB 4.2, change streams are available regardless of the "majority" read concern support; that is, read concern majority support can be either enabled (default) or disabled to use change streams.

In MongoDB 4.0 and earlier, change streams are available only if "majority" read concern support is enabled (default).

### Full Document Lookup of Update Operations

By default, the change stream cursor returns specific field changes/deltas for update operations. You can also configure the change stream to look up and return the current majority-committed version of the changed document. Depending on other write operations that may have occurred between the update and the lookup, the returned document may differ significantly from the document at the time of the update.

Depending on the number of changes applied during the update operation and the size of the full document, there is a risk that the size of the change event document for an update operation is greater than the 16MB BSON document limit. If this occurs, the server closes the change stream cursor and returns an error.

### How to

The following is a simple example on how to execute a call to `DbCollection.watch()`

```dart
var stream = collection.watch(pipeline);
```

**_Note_**

The method returns a `Stream` Object.
As the stream will stay open if not explicitly closed, you have to listen to it with a `listen()` method, any `await`
attempt would lock the program (also `.toList()` for instance).

### Parameters

| Name | Type | Mandatory | Note | Description |
| --- | --- | :---: | --- | --- |
| pipeline | `Map<String, Object>` or `AggregationPipelineBuilder` | :heavy_check_mark: | | Details the aggregation pipeline for records selection |
| batchSize | int | | | Specifies the maximum number of change events to return in each batch of the response from the MongoDB cluster. |
| hint | `String`| | Starting from 4.4  | A string that specifies the index (name) to use to support the query predicate. If you specify an index that does not exist, the operation errors.|
| hintDocument | `Map<String, Object>`| | Starting from 4.4  | A Map that specifies the index ([specification document](https://docs.mongodb.com/manual/reference/method/db.collection.deleteOne/#ex-deleteone-hint)) to use to support the query predicate. It is an alternative way to the hint parameter. If both are specified, the index name is used. |
| changeStreamOptions |  `ChangeStreamOptions` | | | A class containing less used parameters. |

Example with a simple pipeline and full document request:

```dart
var pipeline = AggregationPipelineBuilder().addStage(
      Match(where.oneFrom('fullDocument.custId', [1, 2]).map['\$query']));

  var stream = collection.watch(pipeline,
      changeStreamOptions: ChangeStreamOptions(fullDocument: 'updateLookup'));

  var controller = stream.listen((changeEvent) {
    Map fullDocument = changeEvent.fullDocument;
    // Insert your logic here
  }
```

Example monitoring insert operations:

```dart
var stream = collection.watch(
      <Map<String, Object>>[
        {
          r'$match': {'operationType': 'insert'}
        }
      ]);

  var controller = stream.listen((changeEvent) {
    Map fullDocument = changeEvent.fullDocument;
    // Insert your logic here
  }
```

### Output

The stream `listen` method returns a `ChangeEvent` element.
