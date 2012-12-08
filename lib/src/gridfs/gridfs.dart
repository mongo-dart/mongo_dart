part of mongo_dart;

class GridFS {
  static int DEFAULT_CHUNKSIZE = 256 * 1024;
  static int MAX_CHUNKSIZE = (3.5 * 1000 * 1000).toInt(); // TODO(tsander): Can this be an int?
  
  Db database;
  DbCollection files;
  DbCollection chunks;
  String bucketName; // ?? What is this??

  GridFS(Db this.database, [String collection="fs"]) {
    this.files = database.collection("$collection.files");
    this.chunks = database.collection("$collection.chunks");
    // TODO(tsander): Ensure index??
  }

  Cursor getFileList(SelectorBuilder selectorBuilder) {
    return files.find(selectorBuilder.sortBy("filename", descending:true));
  }

  GridOut find(var id) {}

  GridIn createFile(InputStream input, String filename) {
    return new GridIn(this, filename, input);
  }
}


