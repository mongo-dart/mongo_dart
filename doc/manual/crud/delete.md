# Delete

The new api provides two methods for removing documents from a collection

## deleteOne

Removes a single document from a collection.

### Deletion Order

Dbcollection.deleteOne() deletes the first document that matches the filter. Use a field that is part of a unique index such as `_id` for precise deletions.

### Capped Collections

Dbcollection.deleteOne() is not allowed on a capped collection.

### Sharded Collections

Dbcollection.deleteOne() operations on a sharded collection must include the shard key or the `_id` field in the query specification. Ddcollection.deleteOne() operations in a sharded collection which do not contain either the shard key or the _id field return an error.

The following is a simple example on how to execute a call to deleteOne()

```dart
var writeResult =  await collection.deleteOne(<String, Object>{});
```

**_Note_**

- The method returns a `WriteResult` Object that contains informations on the execution of the operation
- The method return a `Future`, so you will need to await for the method (or use `.then()`)
- The filter parameter is mandatory, even if you want to select all record (`<String, Object>{}`). This is by design to avoid errors in writing the function (like forgetting the selection)

### Parameters

| Name | Type | Mandatory | Note | Description |
| --- | --- | :---: | --- | --- |
| selector | `Map<String, Object>` or `SelectorBuilder` | X | |Specifies deletion criteria using query operators. Specify an empty document { } to delete the first document returned in the collection. If the SelectionBuilder is used, only the filter part is considered |
| writeConcern |  `WriteConcern` | | | A document expressing the write concern. Omit to use the default write concern. |
| collation | `CollationOptions` |  | | Specifies the collation to use for the operation. Collation allows users to specify language-specific rules for string comparison, such as rules for lettercase and accent marks.|
| hint | `String`| | Starting from 4.4  | A string that specifies the index (name) to use to support the query predicate. If you specify an index that does not exist, the operation errors.|
| hintDocument | `Map<String, Object>`| | Starting from 4.4  | A Map that specifies the index ([specification document](https://docs.mongodb.com/manual/reference/method/db.collection.deleteOne/#ex-deleteone-hint)) to use to support the query predicate. It is an alternative way to the hint parameter. If both are specified, the index name is used. |

Example using some parameters:

```dart
var res = await collection.deleteOne(<String, Object>{
          'points': {r'$lte': 20},
          'status': 'P'
        }, writeConcern: WriteConcern(w: 'majority', wtimeout: 5000),
        collation: CollationOptions('fr', strength: 1));
```

Example using hintDocument:

```dart
var res = await collection.deleteOne(<String, Object>{
          'points': {r'$lte': 20},
          'status': 'P'
        }, hintDocument: {'status': 1});
```

### Output

Returns a WriteResult element.

## deleteMany

Removes all documents that match the filter from a collection.

### Capped Collections (deleteMany)

Dbcollection.deleteMany() is not allowed on a capped collection.

### Delete a Single Document

To delete a single document, use `Dbcollection.deleteOne()` instead.
Alternatively, use a field that is a part of a unique index such as `_id`.

The following is a simple example on how to execute a call to deleteMany()

```dart
var writeResult =  await collection.deleteMany(<String, Object>{});
```

**_Note_**

- The method returns a `WriteResult` Object that contains informations on the execution of the operation
- The method return a `Future`, so you will need to await for the method (or use `.then()`)
- The filter parameter is mandatory, even if you want to select all record (`<String, Object>{}`). This is by design to avoid errors in writing the function (like forgetting the selection)

### Parameters (deleteMany)

| Name | Type | Mandatory | Note | Description |
| --- | --- | :---: | --- | --- |
| selector | `Map<String, Object>` or `SelectorBuilder` | X | |Specifies deletion criteria using query operators. Specify an empty document { } to delete the first document returned in the collection. If the SelectionBuilder is used, only the filter part is considered |
| writeConcern |  `WriteConcern` | | | A document expressing the write concern. Omit to use the default write concern. |
| collation | `CollationOptions` |  | | Specifies the collation to use for the operation. Collation allows users to specify language-specific rules for string comparison, such as rules for lettercase and accent marks.|
| hint | `String`| | Starting from 4.4  | A string that specifies the index (name) to use to support the query predicate. If you specify an index that does not exist, the operation errors.|
| hintDocument | `Map<String, Object>`| | Starting from 4.4  | A Map that specifies the index ([specification document](https://docs.mongodb.com/manual/reference/method/db.collection.deleteOne/#ex-deleteone-hint)) to use to support the query predicate. It is an alternative way to the hint parameter. If both are specified, the index name is used. |

Example using some parameters:

```dart
var res = await collection.deleteMany(<String, Object>{
          'points': {r'$lte': 20},
          'status': 'P'
        }, writeConcern: WriteConcern(w: 'majority', wtimeout: 5000),
        collation: CollationOptions('fr', strength: 1));
```

Example using hintDocument:

```dart
var res = await collection.deleteMany(<String, Object>{
          'points': {r'$lte': 20},
          'status': 'P'
        }, hintDocument: {'status': 1});
```

### Output (deleteMany)

Returns a WriteResult element
