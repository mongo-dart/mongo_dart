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
  List<int> contentToDigest = <int>[];
  GridIn(this.fs,
      [String filename, Stream<List<int>> inputStream]) {
    id = ObjectId();
    chunkSize = GridFS.DEFAULT_CHUNKSIZE;
    input = ChunkHandler(chunkSize).transformer.bind(inputStream);
    uploadDate = DateTime.now();
    this.filename = filename;
  }

  @override
  Future<Map<String, dynamic>> save([int chunkSize]) {
    chunkSize ??= this.chunkSize;

    Future<Map<String, dynamic>> result;
    if (!savedChunks) {
      result = saveChunks(chunkSize);
    } else {
      result = Future.value({'ok': 1.0});
    }
    return result;
  }

  Future<Map<String, dynamic>> saveChunks([int chunkSize = 0]) {
    var futures = <Future>[];
    var completer = Completer<Map<String, dynamic>>();

    _onDone() {
      Future.wait(futures).then((list) {
        return finishData();
      }).then((map) {
        completer.complete({});
      });
    }

    chunkSize ??= this.chunkSize;
    if (savedChunks) {
      throw MongoDartError('chunks already saved!');
    }
    if (chunkSize <= 0 || chunkSize > GridFS.MAX_CHUNKSIZE) {
      throw MongoDartError(
          'chunkSize must be greater than zero and less than or equal to GridFS.MAX_CHUNKSIZE');
    }
    input.listen((data) {
      futures.add(dumpBuffer(data));
    }, onDone: _onDone);
    return completer.future;
  }
  // TODO(tsander): OutputStream??

  Future<Map<String, dynamic>> dumpBuffer(List<int> writeBuffer) {
    contentToDigest.addAll(writeBuffer);
    if (writeBuffer.isEmpty) {
      // Chunk is empty, may be last chunk
      return Future.value({});
    }

    var chunk = <String, dynamic>{
      'files_id': id,
      'n': currentChunkNumber,
      'data': BsonBinary.from(writeBuffer)
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
