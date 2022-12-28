import 'package:mongo_dart/mongo_dart.dart'
    show
        InsertOneOptions,
        InsertOperation,
        MongoCollection,
        WriteCommandType,
        WriteResult;

class InsertOneOperation extends InsertOperation {
  Map<String, Object?> document;

  InsertOneOperation(MongoCollection collection, this.document,
      {InsertOneOptions? insertOneOptions, Map<String, Object>? rawOptions})
      : super(
          collection,
          [document],
          insertOptions: insertOneOptions,
          rawOptions: rawOptions,
        );

  Future<WriteResult> executeDocument() async {
    var ret = await super.execute();
    return WriteResult.fromMap(WriteCommandType.insert, ret)
      ..id = ids.first
      ..document = documents.first;
  }
}
