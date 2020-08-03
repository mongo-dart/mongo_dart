part of mongo_dart;

class GridFS {
  static int DEFAULT_CHUNKSIZE = 256 * 1024;
  static int MAX_CHUNKSIZE = (3.5 * 1000 * 1000).toInt();

  Db database;
  DbCollection files;
  DbCollection chunks;
  String bucketName;

  GridFS(this.database, [String collection = 'fs']) {
    files = database.collection('$collection.files');
    chunks = database.collection('$collection.chunks');
    bucketName = collection;

    // TODO(tsander): Ensure index.
  }

  Stream<Map<String, dynamic>> getFileList(SelectorBuilder selectorBuilder) {
    return files.find(selectorBuilder.sortBy('filename', descending: true));
  }

  Future<GridOut> findOne(selector) {
    var completer = Completer<GridOut>();
    files.findOne(selector).then((file) {
      GridOut result;
      if (file != null) {
        result = GridOut(file);
        result.setGridFS(this);
      }
      completer.complete(result);
    });
    return completer.future;
  }

  Future<GridOut> getFile(String fileName) =>
      findOne(where.eq('filename', fileName));

  GridIn createFile(Stream<List<int>> input, String filename) {
    return GridIn(this, filename, input);
  }
}
