part of mongo_dart;

class GridOut extends GridFSFile {
  GridOut(GridFS fs, [Map<String, dynamic>? data]) : super(fs, data);

  Future writeToFilename(String filename) => writeToFile(File(filename));

  Future writeToFile(File file) {
    var sink = file.openWrite(mode: FileMode.write);
    writeTo(sink).then((int length) {
      sink.close();
    });
    return sink.done;
  }

  /// This method uses a different approach in writing to a file.
  /// It uses a temp file to store the data and then renames it to
  /// the correct name. If overwriteExisting file is true,
  /// and a file with the same name exists, it is overwitten,
  /// otherwise a suffix like "(n)" is appended to the file name, where n is
  /// a progressive number not yet assigned to any existing file in the system
  Future<File> toFile(File file,
      {FileMode? mode, bool? overwriteExistingFile}) async {
    overwriteExistingFile ??= false;
    mode ??= FileMode.writeOnly;
    if (mode == FileMode.read) {
      throw ArgumentError('Read file mode not valid for method "toFile()"');
    }
    File tempFile;
    String tempFilePath = '${p.dirname(file.path)}${Platform.pathSeparator}'
        '${p.basenameWithoutExtension(file.path)}_${Uuid().v4()}'
        '${p.extension(file.path)}';
    if (mode == FileMode.append || mode == FileMode.writeOnlyAppend) {
      tempFile = await file.copy(tempFilePath);
    } else {
      tempFile = File(tempFilePath);
    }
    Future<void> addToFile(Map<String, dynamic> chunk) async {
      final bytes = chunk['data'] as BsonBinary;
      await tempFile.writeAsBytes(bytes.byteList,
          mode: FileMode.writeOnlyAppend, flush: true);
    }

    var chunkList = await fs.chunks
        .findOriginal(where.eq('files_id', id).sortBy('n'))
        .toList();
    for (var chunk in chunkList) {
      await addToFile(chunk);
    }
    if (overwriteExistingFile) {
      return tempFile.changeFileNameOnly(file.name);
    }
    return tempFile.changeFileNameOnlySafe(file.name);
  }

  Future<int> writeTo(IOSink out) {
    var length = 0;
    var completer = Completer<int>();
    void addToSink(Map<String, dynamic> chunk) {
      final data = chunk['data'] as BsonBinary;
      out.add(data.byteList);
      length += data.byteList.length;
    }

    fs.chunks
        .findOriginal(where.eq('files_id', id).sortBy('n'))
        .forEach(addToSink)
        .then((_) => completer.complete(length));
    return completer.future;
  }

  /// Removes this document from the bucket
  Future<void> delete() async {
    await fs.files.deleteOne(where.id(id));
    await fs.chunks.deleteMany(where.eq('files_id', id));
  }
}
