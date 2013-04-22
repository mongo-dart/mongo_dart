part of mongo_dart;

class GridIn extends GridFSFile {
  Stream<List<int>> input;
  bool savedChunks = false;
  int currentChunkNumber = 0;
  int currentBufferPosition = 0;
  int totalBytes = 0;
  ObjectId id;
  GridFS fs;
  String filename;
  MD5 messageDigester;

  GridIn(this.fs, [String filename = null, Stream<List<int>> inputStream = null]) {
    id = new ObjectId();
    chunkSize = GridFS.DEFAULT_CHUNKSIZE;
    input = inputStream.transform(new ChunkTransformer(chunkSize));
    uploadDate = new DateTime.now();
    messageDigester = new MD5();
    this.filename = filename;
  }

  Future save([int chunkSize = 0]) {
    if (!?chunkSize) {
      chunkSize = this.chunkSize;
    }

    Future result;
    if (!savedChunks) {
      result = saveChunks(chunkSize);
    } else {
      result = new Future.value({'ok': 1.0});
    }
    return result;
  }

  Future<Map> saveChunks([int chunkSize = 0]) {
    List<Future> futures = new List();
    Completer completer = new Completer();
    
    _onDone() {
      Future.wait(futures).then((list) {
        return finishData();
      }).then((map){
        completer.complete({});
      });
    }
    if (!?chunkSize) {
      chunkSize = this.chunkSize;
    }
    if (savedChunks) {
      throw "chunks already saved!";
    }
    if (chunkSize <= 0 || chunkSize > GridFS.MAX_CHUNKSIZE) {
      throw "chunkSize must be greater than zero and less than or equal to GridFS.MAX_CHUNKSIZE";
    }    
    input.listen((data) {
        futures.add(dumpBuffer(data));
        }, onDone: _onDone);    
    return completer.future;
  }
  // TODO(tsander): OutputStream??

  Future<Map> dumpBuffer( List<int> writeBuffer ) {
    if (writeBuffer.length == 0) {
      // Chunk is empty, may be last chunk
      return new Future.value({});
    }

    Map chunk = {"files_id" : id, "n" : currentChunkNumber, "data": new BsonBinary.from(writeBuffer)};
    currentChunkNumber++;
    totalBytes += writeBuffer.length;
    messageDigester.add(writeBuffer);
    currentBufferPosition = 0;

    return fs.chunks.insert(chunk);
  }

  Future finishData() {
    if (!savedChunks) {
      md5 = CryptoUtils.bytesToHex(messageDigester.close());
      length = totalBytes;
      savedChunks = true;
    }
    return super.save();
  }
}
