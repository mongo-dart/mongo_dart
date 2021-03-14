# Bulk

Performs multiple write operations with controls for order of execution.

## Description

There are two kind of bulk operations: ordered and unordered.
Ordered bulk will execute operations in the order in which they have been declared, and will stop after the first error.
Unordered operation can be reorganized by the driver and executed in a different order. If any error, the operation in error is skipped and the others are executed anyway.

There are two ways of specifying a bulk operation: the collection helper and the bulk class:
The collection helper resemble the shell way of declaring a bulkWrite() operation, while the bulk class allows to define operations in a more concise way.

### Capped Collections

`bulk()` write operations have restrictions when used on a capped collection.

`updateOne` and `updateMany` throw a `WriteError` if the update criteria increases the size of the document being modified.

`replaceOne` throws a `WriteError` if the replacement document has a larger size than the original document.

`deleteOne` and `deleteMany` throw a `WriteError` if used on a capped collection.

## Collection helper

The collection helper let the user define the operations in a shell like way;

```dart
var ret = await collection.bulkWrite([
    {
      /// bulkInsertOne is a convenient constant for "insertOne". 
      /// You can use directly the string, if you like
      bulkInsertOne: {
        bulkDocument: {'_id': 2, 'name': 'Stephen', 'age': 54}
      }
    },
    {
      bulkUpdateOne: {
        bulkFilter: {'cust_num': 99999, 'item': 'abc123', 'status': 'A'},
        bulkUpdate: {
          r'$inc': {'ordered': 1}
        }
      }
    },
  ], ordered: false);
```

The available operations are:

- insertOne
- insertMany
- updateOne
- updateMany
- deleteOne
- deleteMany
- replaceOne

For examples you can [give a look to MongoDb reference](https://docs.mongodb.com/manual/reference/method/db.collection.bulkWrite/)

**Note**
The `insertMany` operation is not defined in shell. The difference with the `insertMany()` method in this driver is that the
collection method has a max limit of documents that can be sent (in last MongoDb release it is 100,000), while the bulk corresponding has not this limitation (because it is able to split the request in smaller batches).

The default execution method is 'ordered'. If you want to run an unordered `bulkWrite` you have to set the `ordered` parameter to `false`.

### Parameters

| Name | Type | Mandatory | Note | Description |
| --- | --- | :---: | --- | --- |
| documents | `List<Map<String, Object>>` | :heavy_check_mark: | | The list of operations |
| ordered | bool | | | States if the execution must be ordered or unordered (defaults to: true, ordered). |
| writeConcern |  `WriteConcern` | | | A document expressing the write concern. Omit to use the default write concern. |

### Output

The method returns a `BulkWriteResult` element.

## Bulk class

The `Bulk` class let the user define the operations in more concise way;
You chose for an ordered or unordered execution using on of the two flavors: `OrderedBulk` or `UnorderedBulk`.

```dart
var bulk = OrderedBulk(collection, writeConcern: WriteConcern(w: 1));
```

or

```dart
var bulk = UnorderedBulk(collection, writeConcern: WriteConcern(w: 1));
```

Once you have a bulk instance you can add the operation with the following methods;

- insertOne
- insertMany
- updateOne | updateOneFromMap
- updateMany | updateManyFromMap
- replaceOne | replaceOneFormMap
- deleteOne | deleteOneFromMap
- deleteMany | deleteManyFromMap

**Note**
The `insertMany` operation is not defined in shell. The difference with the `insertMany()` method in this driver is that the
collection method has a max limit of documents that can be sent (in last MongoDb release it is 100,000), while the bulk corresponding has not this limitation (because it is able to split the request in smaller batches).

### Bulk Parameters

| Name | Type | Mandatory | Note | Description |
| --- | --- | :---: | --- | --- |
| collection | `DbCollection` | :heavy_check_mark: | | The collection instance on which execute the operations |
| writeConcern |  `WriteConcern` | | | A document expressing the write concern. Omit to use the default write concern. |

Once you have inserted all operations you can execute the bul with the `executeDocument` method.

```dart
var ret = await bulk.executeDocument();
```

### insertOne

It simply accept a Map with the document to be inserted;

```dart
 bulk.insertOne({'_id': 5, 'name': 'Mandy', 'age': 21});
 ```

### inserMany

It is like `insertOne` but it accepts a list of documents;

```dart
 bulk.insertMany([
          {'_id': 3, 'name': 'John', 'age': 32},
          {'_id': 4, 'name': 'Mira', 'age': 27},
          {'_id': 7, 'name': 'Luis', 'age': 42}
        ]);
 ```

### updateOne

`updateOne` updates a single document in the collection that matches the filter. If multiple documents match, `updateOne` will update the first matching document only.
Update One requires an `UpdateOneStatement` Object

```dart
 bulk.updateOne(UpdateOneStatement(
            {'cust_num': 99999, 'item': 'abc123', 'status': 'A'},
            ModifierBuilder().inc('ordered', 1).map));
 ```

Alternatively, if you like the shell syntax, you can use the `updateOneFromMap` method, that accepts a shell like map.

```dart
 bulk.updateOneFromMap({
        bulkFilter: {'cust_num': 99999, 'item': 'abc123', 'status': 'A'},
        bulkUpdate: {
          r'$inc': {'ordered': 1}
        }
      });
 ```

### updateMany

`updateMany` updates all documents in the collection that match the filter.
Update Many requires an `UpdateManyStatement` Object

```dart
 bulk.updateMany(UpdateManyStatement(
            {'cust_num': 99999, 'item': 'abc123', 'status': 'A'},
            ModifierBuilder().inc('ordered', 1).map));
 ```

Alternatively, if you like the shell syntax, you can use the `updateManyFromMap` method, that accepts a shell like map.

```dart
 bulk.updateManyFromMap({
        bulkFilter: {'cust_num': 99999, 'item': 'abc123', 'status': 'A'},
        bulkUpdate: {
          r'$inc': {'ordered': 1}
        }
      });
 ```

### replaceOne

`replaceOne` replaces a single document in the collection that matches the filter. If multiple documents match, `replaceOne` will replace the first matching document only.
Replace One requires an `ReplaceOneStatement` Object

```dart
 bulk.replaceOne(ReplaceOneStatement({
          'cust_num': 12345,
          'item': 'tst24',
          'status': 'D'
        }, {
          'cust_num': 12345,
          'item': 'tst24',
          'status': 'Replaced'
        }, upsert: true));
 ```

Alternatively, if you like the shell syntax, you can use the `replaceOneFromMap` method, that accepts a shell like map.

```dart
 bulk.replaceOneFromMap({
              'filter': {'char': 'Meldane'},
              'replacement': {'char': 'Tanys', 'class': 'oracle', 'lvl': 4}
            });
 ```

### deleteOne

`deleteOne` deletes a single document in the collection that match the filter. If multiple documents match, `deleteOne` will delete the first matching document only.
Delete One requires an `DeleteOneStatement` Object

```dart
 bulk.deleteOne(DeleteOneStatement({'cust_num': 99999, 'item': 'abc123', 'status': 'A'}));
 ```

Alternatively, if you like the shell syntax, you can use the `deleteOneFromMap` method, that accepts a shell like map.

```dart
 bulk.deleteOneFromMap({'filter': {'char': 'Brisbane'}});
 ```

### deleteMany

`deleteMany` deletes all documents in the collection that match the filter.
Delete Many requires an `DeleteManyStatement` Object

```dart
 bulk.deleteMany(DeleteManyStatement({'status': 'D'}));
 ```

Alternatively, if you like the shell syntax, you can use the `deleteManyFromMap` method, that accepts a shell like map.

```dart
 bulk.deleteManyFromMap({bulkFilter: {'status': 'D'},});
 ```

### Output - executeDocument

The method returns a `BulkWriteResult` element.

### Output - executBulk

`executeBulk` is an alternative way of executing a bulkWrite operation. Instead of a `BulkWriteResult` object it returns the list of documents returned from the server.
