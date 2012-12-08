part of mongo_dart;

class GridIn extends GridFSFile {
  InputStream input;
  bool closeStreamOnPersist;
  bool savedChunks = false;
  List<int> buffer = null; // Is this needed?
  int currentChunkNumber = 0;
  int currentBufferPosition = 0;
  int totalBytes = 0;
  ObjectId id;
  GridFS fs;
  String filename;

  // Message digest?
  OutputStream outputStream = null;

  GridIn(this.fs, [this.filename = null, this.input = null, this.closeStreamOnPersist = false]) {
    id = new ObjectId();
    chunkSize = GridFS.DEFAULT_CHUNKSIZE;
    uploadDate = new Date.now();
    // MD5 message digest??
    // reset digester
    // buffer??
  }

  void save([int chunkSize = this.chunkSize]) {
    if (outputStream != null) {
      throw "cannot mix OutputStream and regular save()";
    }

    if (!savedChunks) {
      saveChunks(chunkSize);
    }
    super.save();
  }

  void saveChunks([int chunkSize = this.chunkSize]) {
    if (outputStream != null) {
      throw "cannot mix OutputStream and regular save()";
    }
    if (savedChunks) {
      throw "chunks already saved!";
    }
    if (chunkSize <= 0 || chunkSize > GridFS.MAX_CHUNKSIZE) {
      throw "chunkSize must be greater than zero and less than or equal to GridFS.MAX_CHUNKSIZE";
    }
    input.onData = () {
      List buffer = new List<int>(chunkSize);
      int bytesRead = 0;
      do {
        currentBufferPosition = 0;
        while (currentBufferPosition < chunkSize) {
          bytesRead = input.readInto(buffer, currentBufferPosition, chunkSize - currentBufferPosition);
          if (bytesRead > 0) {
            currentBufferPosition += bytesRead;
          } else {
            break;
          }
        }
        
        dumpBuffer(true);
      } while (bytesRead > 0);
      finishData();
    };
  }
  // TODO(tsander): OutputStream??

  void dumpBuffer( bool writePartial ) {
    if ( (currentBufferPosition < chunkSize) && !writePartial) {
      // Chunk not completed yet
      return;
    }
    if (currentBufferPosition == 0) {
      // Chunk is empty, may be last chunk
      return;
    }
    
    List<int> writeBuffer = buffer;
    if ( currentBufferPosition != chunkSize ) {
      writeBuffer = new List<int>(currentBufferPosition);
      writeBuffer.setRange(0, currentBufferPosition, buffer);
    }
    Map chunk = {"files_id" : id, "n" : currentChunkNumber, "data": writeBuffer};
    fs.chunks.save(chunk);
    
    currentChunkNumber++;
    totalBytes += writeBuffer.length;
    // Update md5 digest??
    currentBufferPosition = 0;
  }

  void finishData() {
    if (!savedChunks) {
      // TODO md5 calculate
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
  }
}
