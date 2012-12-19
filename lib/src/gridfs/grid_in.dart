part of mongo_dart;

class GridIn extends GridFSFile {
  ChunkedInputStream input;
  bool savedChunks = false;
  int currentChunkNumber = 0;
  int currentBufferPosition = 0;
  int totalBytes = 0;
  ObjectId id;
  GridFS fs;
  String filename;
  MD5 messageDigester;

  GridIn(this.fs, [this.filename = null, InputStream inputStream = null]) {
    input = new ChunkedInputStream(inputStream);
    id = new ObjectId();
    chunkSize = GridFS.DEFAULT_CHUNKSIZE;
    uploadDate = new Date.now();
    messageDigester = new MD5();
  }

  Future save([int chunkSize = 0]) {
    if (!?chunkSize) {
      chunkSize = this.chunkSize;
    }

    Future result;
    if (!savedChunks) {
      result = saveChunks(chunkSize);
    } else {
      result = new Future.immediate({'ok': 1.0});
    }
    return result;
  }

  Future<Map> saveChunks([int chunkSize = 0]) {
    if (!?chunkSize) {
      chunkSize = this.chunkSize;
    }
    if (savedChunks) {
      throw "chunks already saved!";
    }
    if (chunkSize <= 0 || chunkSize > GridFS.MAX_CHUNKSIZE) {
      throw "chunkSize must be greater than zero and less than or equal to GridFS.MAX_CHUNKSIZE";
    }
    input.chunkSize = chunkSize;
    List<Future> futures = new List();
    Completer completer = new Completer();
    
    input.onData = () {
      List<int> buffer = input.read();
      futures.add(dumpBuffer(buffer));
    };

    input.onClosed = () {
      Futures.wait(futures).chain((list) {
        return finishData();
      }).then((map){
        completer.complete({});
      });
    };
    
    return completer.future;
  }
  // TODO(tsander): OutputStream??

  Future<Map> dumpBuffer( List<int> writeBuffer ) {
    if (writeBuffer.length == 0) {
      // Chunk is empty, may be last chunk
      return new Future.immediate({});
    }

    Map chunk = {"files_id" : id, "n" : currentChunkNumber, "data": new BsonBinary.from(writeBuffer)};
    currentChunkNumber++;
    totalBytes += writeBuffer.length;
    messageDigester.update(writeBuffer);
    currentBufferPosition = 0;

    return fs.chunks.insert(chunk, safeMode:true);
  }

  Future finishData() {
    if (!savedChunks) {
      md5 = CryptoUtils.bytesToHex(messageDigester.digest());
      length = totalBytes;
      savedChunks = true;
    }
    return super.save();
  }
}
