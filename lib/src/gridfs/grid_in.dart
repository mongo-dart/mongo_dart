part of mongo_dart;

class GridIn extends GridFSFile {
  RandomAccessFile input;
  bool closeStreamOnPersist;
  bool savedChunks = false;
  List<int> buffer = null; // Is this needed?
  int currentChunkNumber = 0;
  int currentBufferPosition = 0;
  int totalBytes = 0;
  ObjectId id;
  GridFS fs;
  String filename;
  MD5 messageDigester;

  GridIn(this.fs, [this.filename = null, this.input = null, this.closeStreamOnPersist = false]) {
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
    List<Future> futures = new List();
    Completer completer = new Completer();
    buffer = new List<int>(chunkSize);
    int bytesRead = 0;
    do {
      currentBufferPosition = 0;
      while (currentBufferPosition < chunkSize) {
        bytesRead = input.readListSync(buffer, currentBufferPosition, chunkSize - currentBufferPosition);
        if (bytesRead > 0) {
          currentBufferPosition += bytesRead;
        } else {
          break;
        }
      }

      futures.add(dumpBuffer(true));
    } while (bytesRead > 0);

    Futures.wait(futures).chain((list) {
      return finishData();
    }).then((map){
      completer.complete({});
    });
    return completer.future;
  }
  // TODO(tsander): OutputStream??

  Future<Map> dumpBuffer( bool writePartial ) {
    if ( (currentBufferPosition < chunkSize) && !writePartial) {
      // Chunk not completed yet
      return new Future.immediate({});
    }
    if (currentBufferPosition == 0) {
      // Chunk is empty, may be last chunk
      return new Future.immediate({});
    }

    List<int> writeBuffer = buffer;
    if ( currentBufferPosition != chunkSize ) {
      writeBuffer = new List<int>(currentBufferPosition);
      writeBuffer.setRange(0, currentBufferPosition, buffer);
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
      try {
        if (input != null && closeStreamOnPersist) {
          input.close();
        }
      } catch(e) {
        // Ignore
      }
    }
    return super.save();
  }
}
