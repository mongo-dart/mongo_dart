part of mongo_dart;

class GridOut extends GridFSFile {
  GridOut([Map<String, dynamic> data]) : super(data);

  Future writeToFilename(String filename) {
    return writeToFile(File(filename));
  }

  Future writeToFile(File file) {
    var sink = file.openWrite(mode: FileMode.write);
    writeTo(sink).then((int length) {
      sink.close();
    });
    return sink.done;
  }

  Future<int> writeTo(IOSink out) {
    var length = 0;
    var completer = Completer<int>();
    addToSink(Map<String, dynamic> chunk) {
      final data = chunk['data'] as BsonBinary;
      out.add(data.byteList);
      length += data.byteList.length;
    }

    fs.chunks
        .find(where.eq('files_id', id).sortBy('n'))
        .forEach(addToSink)
        .then((_) => completer.complete(length));
    return completer.future;
  }
}
