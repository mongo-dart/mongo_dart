part of mongo_dart;

class GridIn extends GridFSFile {
  Stream<List<int>> input;
  bool savedChunks = false;
  int currentChunkNumber = 0;
  int currentBufferPosition = 0;
  int totalBytes = 0;
  GridFS fs;
  String filename;

  ///TODO Review that code. Currently it sums all file's content in one (potentially big) List, to get MD5 hash
  /// Probably we should use some Stream api here
  List<int> contentToDigest = new List<int>();
  GridIn(this.fs,
      [String filename = null, Stream<List<int>> inputStream = null]) {
    id = new ObjectId();
    chunkSize = GridFS.DEFAULT_CHUNKSIZE;
    input = inputStream.transform(new ChunkHandler(chunkSize).transformer);
    uploadDate = new DateTime.now();
    this.filename = filename;
  }

  Future<Map> save([int chunkSize]) {
    if (chunkSize == null) {
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
      }).then((map) {
        completer.complete({});
      });
    }

    if (chunkSize == null) {
      chunkSize = this.chunkSize;
    }
    if (savedChunks) {
      throw new MongoDartError('chunks already saved!');
    }
    if (chunkSize <= 0 || chunkSize > GridFS.MAX_CHUNKSIZE) {
      throw new MongoDartError(
          'chunkSize must be greater than zero and less than or equal to GridFS.MAX_CHUNKSIZE');
    }
    input.listen((data) {
      futures.add(dumpBuffer(data));
    }, onDone: _onDone);
    return completer.future;
  }
  // TODO(tsander): OutputStream??

  Future<Map> dumpBuffer(List<int> writeBuffer) {
    contentToDigest.addAll(writeBuffer);
    if (writeBuffer.length == 0) {
      // Chunk is empty, may be last chunk
      return new Future.value({});
    }

    Map chunk = {
      "files_id": id,
      "n": currentChunkNumber,
      "data": new BsonBinary.from(writeBuffer)
    };
    currentChunkNumber++;
    totalBytes += writeBuffer.length;
    contentToDigest.addAll(writeBuffer);
    currentBufferPosition = 0;

    return fs.chunks.insert(chunk);
  }

  Future finishData() {
    if (!savedChunks) {
      md5 = crypto.md5.convert(contentToDigest).toString();
      length = totalBytes;
      savedChunks = true;
    }
    return super.save();
  }
}
