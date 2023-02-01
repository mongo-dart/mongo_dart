import '../../command/command.dart';
import '../../session/client_session.dart';
import '../database.dart';

class MongoCollectionV1 extends MongoCollection {
  MongoCollectionV1(super.db, super.collectionName) : super.protected();

  // Insert one document into this collection
  // Returns a WriteResult object
  @override
  Future<InsertOneDocumentRec> insertOne(MongoDocument document,
          {ClientSession? session, InsertOneOptions? insertOneOptions}) async =>
      InsertOneOperationV1(this, document,
              insertOneOptions: insertOneOptions?.toOneV1)
          .executeDocument(session: session);

  /// Insert many document into this collection
  /// Returns a BulkWriteResult object
  @override
  Future<InsertManyDocumentRec> insertMany(List<MongoDocument> documents,
          {ClientSession? session,
          InsertManyOptions? insertManyOptions}) async =>
      InsertManyOperationV1(this, documents,
              insertManyOptions: insertManyOptions?.toManyV1)
          .executeDocument(session: session);
}
