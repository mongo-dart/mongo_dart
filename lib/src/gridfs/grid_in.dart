part of mongo_dart;

class GridIn extends GridFSFile {
  late Stream<Uint8List> input;
  bool savedChunks = false;
  int currentChunkNumber = 0;
  int totalBytes = 0;

  @override
  String? filename;

  /// Used for MD5 calculation, now deprecated
  //Uint8List contentToDigest = Uint8List(0);
  GridIn._(GridFS fs, String filename, Stream<List<int>> inputStream)
      : super(fs) {
    id = ObjectId();
    input = ChunkHandler(chunkSize).transformer.bind(inputStream);
    uploadDate = DateTime.now();
    this.filename = filename;
  }

  @override
  Future<Map<String, dynamic>> save([int? chunkSize]) async {
    if (!savedChunks) {
      return saveChunks(chunkSize);
    }
    return {'ok': 1.0};
  }

  Future<Map<String, dynamic>> saveChunks([int? chunkSize]) async {
    chunkSize ??= this.chunkSize;

    if (savedChunks) {
      throw MongoDartError('chunks already saved!');
    }
    if (chunkSize <= 0 || chunkSize > GridFS.MAX_CHUNKSIZE) {
      throw MongoDartError(
          'chunkSize must be greater than zero and less than or equal to GridFS.MAX_CHUNKSIZE');
    }

    await for (var data in input) {
      await dumpBuffer(data);
    }

    return finishData();
  }

  Future<Map<String, dynamic>> dumpBuffer(Uint8List writeBuffer) async {
    if (writeBuffer.isEmpty) {
      // Chunk is empty, may be last chunk
      return <String, dynamic>{};
    }

    var chunk = <String, dynamic>{
      'files_id': id,
      'n': currentChunkNumber,
      'data': BsonBinary.from(writeBuffer)
    };
    currentChunkNumber++;

    totalBytes += writeBuffer.length;
    /*  var actualLength = contentToDigest.length;
    var contentTemp = Uint8List(totalBytes);
    contentTemp.setAll(0, contentToDigest);
    contentTemp.setAll(actualLength, writeBuffer);
    contentToDigest = contentTemp; */

    return fs.chunks.insert(chunk);
  }

  Future<Map<String, dynamic>> finishData() async {
    if (!savedChunks) {
      //md5 = crypto.md5.convert(contentToDigest).toString();
      length = totalBytes;
      savedChunks = true;
    }
    return super.save();
  }
}
