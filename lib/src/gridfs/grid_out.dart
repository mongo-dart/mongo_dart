part of mongo_dart;

class GridOut extends GridFSFile {

  GridOut([Map data]) : super(data);

  Future writeToFilename(String filename) {
    return writeToFile(new File(filename));
  }

  Future writeToFile(File file) {
    var completer = new Completer();
    var sink = file.openWrite(mode: FileMode.WRITE);    
    writeTo(sink).then((int length) {
      sink.close();
    });
    return sink.done;
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
