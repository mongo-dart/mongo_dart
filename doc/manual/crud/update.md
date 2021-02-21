# Update

The new api provides four methods for updating documents in a collection.
The logic is delinead in the following table:
| Name | Update Document (fields) | Replacement Document (document) | One Document | Many Documents |
| --- | :---: | :---: | :---: | :---: |
| | Contains only update operator expressions| Contains only \<field1\>: \<value1\> pairs.|||
| updateOne | :heavy_check_mark: | | :heavy_check_mark: | |
| replaceOne |  | :heavy_check_mark: | :heavy_check_mark: | |
| updateMany | :heavy_check_mark: |  |  |:heavy_check_mark: |
| modernUpdate | :heavy_check_mark: | | :heavy_check_mark: | :heavy_check_mark: |

## modernUpdate

Modifies an existing document or documents in a collection. The method can modify specific fields of an existing document or documents or replace an existing document entirely, depending on the update parameter.

By default, the modernUpdate() method updates a single document. Include the option multi: true to update all documents that match the query criteria.

The `modernUpdate()` method by default returns a Map instead of the `WriteResult` object (like the shell commnad and also `updateOne()`, `replaceOne()` and `updateMany()` methods). For compatibility reason with the `legacyUpdate()` methods, a `modernReply` parameter is provided (defaults to `true`). If set to false, a compatible `legacyUpdate()` method `Map` is returned (`getLastError()` return value)

### Access Control

On deployments running with authorization, the user must have access that includes the following privileges:

- update action on the specified collection(s).
- find action on the specified collection(s).
- insert action on the specified collection(s) if the operation results in an upsert.

The built-in role readWrite provides the required privileges.

### Sharded Collections

There are some limits in using update on a sharded collection, see [db.collection.update()](https://docs.mongodb.com/manual/reference/method/db.collection.update/#behavior)

The following is a simple example on how to execute a call to modernUpdate()

```dart
var res = await collection.modernUpdate(where.eq('member', 'abc123'), ModifierBuilder().set('status', 'A'));
```

### Parameters

| Name | Type | Mandatory | Note | Description |
| --- | --- | :---: | --- | --- |
| selector | `Map<String, Object>` or `SelectorBuilder` | :heavy_check_mark: | |Specifies selection criteria using query operators. |
| update | `Map<String, Object>` or `ModifierBuilder` or `List<Map<String, Object>>` | :heavy_check_mark: | The aggregation pipeline is available starting from ver. 4.2 | The modifications to apply. Can be one of the following: Update document, Replacement document or Aggregation pipeline |
| upsert | `bool` | | | If set to true, creates a new document when no document matches the query criteria. The default value is false, which does not insert a new document when no match is found. |
| multi | `bool` | | | If set to true, updates multiple documents that meet the query criteria. If set to false, updates one document. The default value is false |
| writeConcern |  `WriteConcern` | | | A document expressing the write concern. Omit to use the default write concern. |
| collation | `CollationOptions` |  | | Specifies the collation to use for the operation. Collation allows users to specify language-specific rules for string comparison, such as rules for lettercase and accent marks.|
| arrayFilters | Map | | | An array of filter documents that determine which array elements to modify for an update operation on an array field. See [Specify arrayFilters for Array Update Operations](https://docs.mongodb.com/manual/reference/method/db.collection.update/#update-arrayfilters).|
| hint | `String`| | Starting from 4.4  | A string that specifies the index (name) to use to support the query predicate. If you specify an index that does not exist, the operation errors.|
| hintDocument | `Map<String, Object>`| | Starting from 4.4  | A Map that specifies the index ([specification document](https://docs.mongodb.com/manual/reference/method/db.collection.deleteOne/#ex-deleteone-hint)) to use to support the query predicate. It is an alternative way to the hint parameter. If both are specified, the index name is used. |
| modernReply | `bool` | | | If true (default), returns a Map corresponding to a WriteResult Object, if false returns a map compatible with the `legacyUpdate()` method (getLastError return value) |

Example using aggregation pipeline:

```dart
var res = await collection.modernUpdate(
            null,
            (AggregationPipelineBuilder()
                  ..addStage(SetStage({
                    'status': 'Modified',
                    'comments': [r'$misc1', r'$misc2']
                  }))
                  ..addStage(Unset(['misc1', 'misc2'])))
                .build(),
            multi: true,
            writeConcern: WriteConcern(w: 'majority', wtimeout: 5000));
```

Example using array filters:

```dart
var res = await collection.modernUpdate(where.gte('grades', 100),
            ModifierBuilder().set(r'grades.$[element]', 100),
            arrayFilters: [
              {
                'element': {r'$gte': 100}
              }
            ],
            multi: true);
```

**_Note_**

- The method return a `Future`, so you will need to await for the method (or use `.then()`)

### Output

Returns a WriteResult **Map**.

## updateOne

Updates a single document within the collection based on the filter. `updateOne()` finds the first document that matches the filter and applies the specified update modifications.

`updateOne()` method can accept a document that only contains update operator expressions (field modifications). For updating an entire document see `replaceOne()`.

### Access Control (updateOne)

On deployments running with authorization, the user must have access that includes the following privileges:

- update action on the specified collection(s).
- find action on the specified collection(s).
- insert action on the specified collection(s) if the operation results in an upsert.

The built-in role readWrite provides the required privileges.

### Upsert

If upsert: true and no documents match the filter, `updateOne()` creates a new document based on the filter criteria and update modifications. See Update with Upsert.

If you specify upsert: true on a sharded collection, you must include the full shard key in the filter. For additional db.collection.updateOne() behavior on a sharded collection, see Sharded Collections.

### Sharded Collections (updateOne)

There are some limits in using update on a sharded collection, see [db.collection.updateOne()](https://docs.mongodb.com/manual/reference/method/db.collection.updateOne/#updateone-sharded-collection)

The following is a simple example on how to execute a call to `updateOnee()`

```dart
var res = await collection.updateOne(where.eq('member', 'abc123'), ModifierBuilder().inc('points', 1));
```

### Parameters (updateOne)

| Name | Type | Mandatory | Note | Description |
| --- | --- | :---: | --- | --- |
| selector | `Map<String, Object>` or `SelectorBuilder` | :heavy_check_mark: | |Specifies selection criteria using query operators. |
| update | `Map<String, Object>` or `ModifierBuilder` or `List<Map<String, Object>>` | :heavy_check_mark: | The aggregation pipeline is available starting from ver. 4.2 | The modifications to apply. Can be one of the following: Update document or Aggregation pipeline |
| upsert | `bool` | | | If set to true, creates a new document when no document matches the query criteria. The default value is false, which does not insert a new document when no match is found. |
| writeConcern |  `WriteConcern` | | | A document expressing the write concern. Omit to use the default write concern. |
| collation | `CollationOptions` |  | | Specifies the collation to use for the operation. Collation allows users to specify language-specific rules for string comparison, such as rules for lettercase and accent marks.|
| arrayFilters | Map | | | An array of filter documents that determine which array elements to modify for an update operation on an array field. See [Specify arrayFilters for Array Update Operations](https://docs.mongodb.com/manual/reference/method/db.collection.update/#update-arrayfilters).|
| hint | `String`| | Starting from 4.4  | A string that specifies the index (name) to use to support the query predicate. If you specify an index that does not exist, the operation errors.|
| hintDocument | `Map<String, Object>`| | Starting from 4.4  | A Map that specifies the index ([specification document](https://docs.mongodb.com/manual/reference/method/db.collection.deleteOne/#ex-deleteone-hint)) to use to support the query predicate. It is an alternative way to the hint parameter. If both are specified, the index name is used. |

Example using collation:

```dart
var res = await collection.updateOne(where.eq('category', 'cafe').eq('status', 'a'), ModifierBuilder().set('status', 'Updated'), collation: CollationOptions('fr', strength: 1));
```

**_Note_**

- The method returns a `WriteResult` Object that contains informations on the execution of the operation
- The method return a `Future`, so you will need to await for the method (or use `.then()`)

### Output (updateOne)

Returns a WriteResult **object**.

## replaceOne

Replaces a single document within the collection based on the filter. `replaceOne()` replaces the first matching document in the collection that matches the filter, using the replacement document.

### Upsert (replaceOne)

If upsert: true and no documents match the filter, `replaceOne()` creates a new document based on the replacement document.

If you specify upsert: true on a sharded collection, you must include the full shard key in the filter. For additional `replaceOne()` behavior on a sharded collection, see [Sharded Collections](https://docs.mongodb.com/manual/reference/method/db.collection.replaceOne/#replaceone-sharded-collection).

### Capped Collections (replaceOne)

If a replacement operation changes the document size, the operation will fail.

### Sharded Collections (replaceOne)

There are some limits in using update on a sharded collection, see [db.collection.replaceOne()](https://docs.mongodb.com/manual/reference/method/db.collection.replaceOne/#replaceone-sharded-collection)

The following is a simple example on how to execute a call to `replaceOne()`

```dart
var res = await collection.replaceOne(where.eq('name', 'Central Perk Cafe'), <String, Object>{
          'name': 'Central Park Cafe',
          'Borough': 'Manhattan'
        });
```

### Parameters (replaceOne)

| Name | Type | Mandatory | Note | Description |
| --- | --- | :---: | --- | --- |
| selector | `Map<String, Object>` or `SelectorBuilder` | :heavy_check_mark: | |Specifies selection criteria using query operators. |
| update | `Map<String, Object>` or `ModifierBuilder` or `List<Map<String, Object>>` | :heavy_check_mark: | The aggregation pipeline is available starting from ver. 4.2 | The modifications to apply. Can be one of the following: Update document or Aggregation pipeline |
| upsert | `bool` | | | If set to true, creates a new document when no document matches the query criteria. The default value is false, which does not insert a new document when no match is found. |
| writeConcern |  `WriteConcern` | | | A document expressing the write concern. Omit to use the default write concern. |
| collation | `CollationOptions` |  | | Specifies the collation to use for the operation. Collation allows users to specify language-specific rules for string comparison, such as rules for lettercase and accent marks.|
| hint | `String`| | Starting from 4.4  | A string that specifies the index (name) to use to support the query predicate. If you specify an index that does not exist, the operation errors.|
| hintDocument | `Map<String, Object>`| | Starting from 4.4  | A Map that specifies the index to use to support the query predicate. It is an alternative way to the hint parameter. If both are specified, the index name is used. |

**_Note_**

- The method returns a `WriteResult` Object that contains informations on the execution of the operation
- The method return a `Future`, so you will need to await for the method (or use `.then()`)

### Output (replaceOne)

Returns a WriteResult **object**.

## updateMany

Updates all documents that match the specified filter for a collection, using the update criteria to apply modifications.

### Access Control (updateMany)

On deployments running with authorization, the user must have access that includes the following privileges:

- update action on the specified collection(s).
- find action on the specified collection(s).
- insert action on the specified collection(s) if the operation results in an upsert.

The built-in role readWrite provides the required privileges.

### Upsert (updateMany)

If upsert: true and no documents match the filter, `updateMany()` creates a new document based on the filter criteria and update parametera. See [Update Multiple Documents with Upsert](https://docs.mongodb.com/manual/reference/method/db.collection.updateMany/#updatemany-example-update-multiple-documents-with-upsert).

### Capped Collections (updateMany)

If an update operation changes the document size, the operation will fail.

### Sharded Collections (updateMany)

For a `updateMany()` operation that includes upsert: true and is on a sharded collection, you must include the full shard key in the filter.

```dart
var res = await collection.updateOne(where.eq('member', 'abc123'), ModifierBuilder().inc('points', 1));
```

### Parameters (updateMany)

| Name | Type | Mandatory | Note | Description |
| --- | --- | :---: | --- | --- |
| selector | `Map<String, Object>` or `SelectorBuilder` | :heavy_check_mark: | |Specifies selection criteria using query operators. |
| update | `Map<String, Object>` or `ModifierBuilder` or `List<Map<String, Object>>` | :heavy_check_mark: | The aggregation pipeline is available starting from ver. 4.2 | The modifications to apply. Can be one of the following: Update document or Aggregation pipeline |
| upsert | `bool` | | | When true, updateMany() either: Creates a new document if no documents match the filter. For more details see upsert behavior or Updates documents that match the filter. To avoid multiple upserts, ensure that the filter fields are uniquely indexed. Defaults to false. |
| writeConcern |  `WriteConcern` | | | A document expressing the write concern. Omit to use the default write concern. |
| collation | `CollationOptions` |  | | Specifies the collation to use for the operation. Collation allows users to specify language-specific rules for string comparison, such as rules for lettercase and accent marks.|
| arrayFilters | Map | | | An array of filter documents that determine which array elements to modify for an update operation on an array field. See [Specify arrayFilters for Array Update Operations](https://docs.mongodb.com/manual/reference/method/db.collection.update/#update-arrayfilters).|
| hint | `String`| | Starting from 4.4  | A string that specifies the index (name) to use to support the query predicate. If you specify an index that does not exist, the operation errors.|
| hintDocument | `Map<String, Object>`| | Starting from 4.4  | A Map that specifies the index ([specification document](https://docs.mongodb.com/manual/reference/method/db.collection.deleteOne/#ex-deleteone-hint)) to use to support the query predicate. It is an alternative way to the hint parameter. If both are specified, the index name is used. |

Example using Write Concern:

```dart
  var res = await collection.updateMany(
            where, ModifierBuilder().set('status', 'A').inc('points', 1),
            writeConcern: WriteConcern(w: 'majority', wtimeout: 5000));
```

Example using Aggregation Pipeline:

```dart
          var res = await collection.updateMany(
            null,
            (AggregationPipelineBuilder()
                  ..addStage(SetStage({
                    'status': 'Modified',
                    'comments': [r'$misc1', r'$misc2']
                  }))
                  ..addStage(Unset(['misc1', 'misc2'])))
                .build());
```

Example using Array Filters:

```dart
        var res = await collection.updateMany(where.gte('grades', 100),
            ModifierBuilder().set(r'grades.$[element]', 100),
            arrayFilters: [
              {
                'element': {r'$gte': 100}
              }
            ]);
```

**_Note_**

- The method returns a `WriteResult` Object that contains informations on the execution of the operation
- The method return a `Future`, so you will need to await for the method (or use `.then()`)

### Output (updateMany)

Returns a WriteResult **object**.
