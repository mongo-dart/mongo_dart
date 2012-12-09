part of mongo_dart;

class GridOut extends GridFSFile {

  GridOut([Map data]) {
    // TODO there is a better way
    if (?data) {
      this.data = data;
    }
  }

  InputStream get inputStream {
    // TODO do this
    return null;
  }

  Future<List<int>> getChunk(int i) {
    if (fs == null) {
      // TODO throw error
    }
    Completer completer = new Completer();
    // TODO(tsander): Would it be better to ask for all the chunks instead of
    // one at a time?
    fs.chunks.findOne(where.eq("files_id", id).eq("n", i))
    ..handleException((e){
      // TODO better error handling.
      print(e);
    })
    ..then((Map chunk) {
      List<int> result = null;
      if (chunk != null) {
        BsonBinary data = chunk["data"];
        result = data.byteList;
      }
      completer.complete(result);
    });
    return completer.future;
  }

  Future<int> writeToFilename(String filename) {
    return writeToFile(new File(filename));
  }

  Future<int> writeToFile(File file) {
    OutputStream out = file.openOutputStream(FileMode.WRITE);
    Future<int> written = writeTo(out);
    written.chain((int length) {
      out.close();
      return new Future.immediate(length);
    });
    return written;
  }

  Future<int> writeTo(OutputStream out) {
    final int nc = numChunks();
    // TODO(tsander): Find a better name??
    Future<List<int>> chain = null;
    Completer completer = new Completer();
    for ( int i = 0; i<nc; i++ ){
      if (chain == null) {
        chain = getChunk(i);
      } else {
        chain = chain.chain((List<int> buffer){
          return getChunk(i);
        });
      }
      chain = chain.chain((List<int> buffer) {
        if (buffer != null) {
          out.write(buffer, true);
          out.flush();
        }
        return new Future.immediate(buffer);
      });
    }
    if (chain != null) {
      chain.then((List<int> buffer){
        completer.complete(length);
      });
    } else {
      return new Future.immediate(length);
    }
    return completer.future;
  }
}
