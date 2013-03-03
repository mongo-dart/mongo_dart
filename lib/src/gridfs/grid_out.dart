part of mongo_dart;

class GridOut extends GridFSFile {

  GridOut([Map data]) {
    // TODO there is a better way
    if (?data) {
      this.data = data;
    }
  }
  
  Future<List<int>> getChunk(int i) {
    if (fs == null) {
      // TODO throw error
    }
    Completer completer = new Completer();
    // TODO(tsander): Would it be better to ask for all the chunks instead of
    // one at a time?
    fs.chunks.findOne(where.eq("files_id", id).eq("n", i))
    ..catchError((e){
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
    IOSink out = file.openWrite(FileMode.WRITE);    
    Future<int> written = writeTo(out);
    written.then((int length) {
      out.close();
      return new Future.immediate(length);
    });
    return written;
  }

  Future<int> writeTo(IOSink out) {
    int length = 0;
    Completer completer = new Completer();
    addToSink(Map chunk) {
      BsonBinary data = chunk["data"];
      out.add(data.byteList);
      length += data.byteList.length;
    }  
    fs.chunks.find(where.eq("files_id", id).sortBy('n'))
      .each(addToSink)
      .then((_) => completer.complete(length));
    return completer.future;
  }
}
