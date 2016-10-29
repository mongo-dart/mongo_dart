part of mongo_dart;

class GridFS {
  static int DEFAULT_CHUNKSIZE = 256 * 1024;
  static int MAX_CHUNKSIZE = (3.5 * 1000 * 1000).toInt();

  Db database;
  DbCollection files;
  DbCollection chunks;
  String bucketName;

  GridFS(Db this.database, [String collection = "fs"]) {
    this.files = database.collection("$collection.files");
    this.chunks = database.collection("$collection.chunks");
    bucketName = collection;

    // TODO(tsander): Ensure index.
  }

  Stream<Map> getFileList(SelectorBuilder selectorBuilder) {
    return files.find(selectorBuilder.sortBy("filename", descending: true));
  }

  Future<GridOut> findOne(dynamic selector) async {
    Map file = await files.findOne(selector);
    GridOut result = null;
    if (file != null) {
      result = new GridOut(file);
      result.setGridFS(this);
    }
    return result;
  }

  Future<GridOut> getFile(String fileName) =>
      findOne(where.eq('filename', fileName));

  GridIn createFile(Stream<List<int>> input, String filename) {
    return new GridIn(this, filename, input);
  }
}
