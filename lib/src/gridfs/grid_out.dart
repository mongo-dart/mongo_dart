part of '../../mongo_dart.dart';

class GridOut extends GridFSFile {
  GridOut(super.fs, [super.data]);

  Future writeToFilename(String filename) => writeToFile(XFile(filename));

  Future writeToFile(XFile file) {
    Stream<Uint8List> fileStream = file.openRead();
    final sink = StreamController<Uint8List>()..addStream(fileStream);
    writeTo(sink);
    return sink.close();
  }

  /// This method uses a different approach in writing to a file.
  /// It uses a temp file to store the data and then renames it to
  /// the correct name. If overwriteExisting file is true,
  /// and a file with the same name exists, it is overwitten,
  /// otherwise a suffix like "(n)" is appended to the file name, where n is
  /// a progressive number not yet assigned to any existing file in the system
  Future<XFile> toFile(XFile file,
      {XFileMode? mode, bool? overwriteExistingFile}) async {
    overwriteExistingFile ??= false;
    mode ??= XFileMode.writeOnly;
    if (mode == XFileMode.read) {
      throw ArgumentError('Read file mode not valid for method "toFile()"');
    }
    XFile tempFile;
    String tempFilePath = '${p.dirname(file.path)}${Platform.pathSeparator}'
        '${p.basenameWithoutExtension(file.path)}_${Uuid().v4()}'
        '${p.extension(file.path)}';
    if (mode == XFileMode.append || mode == XFileMode.writeOnlyAppend) {
      tempFile = await file.copyWith(path: tempFilePath);
    } else {
      tempFile = XFile(tempFilePath);
    }
    Future<void> addToFile(Map<String, dynamic> chunk) async {
      final bytes = chunk['data'] as BsonBinary;
      await XFile.fromData(
        bytes.byteList,
        path: tempFile.path,
        name: tempFile.name,
        mimeType: tempFile.mimeType,
        length: await tempFile.length(),
        lastModified: await tempFile.lastModified(),
      ).saveTo(tempFile.path);
    }

    var chunkList =
        await fs.chunks.find(where.eq('files_id', id).sortBy('n')).toList();
    for (var chunk in chunkList) {
      await addToFile(chunk);
    }
    if (overwriteExistingFile) {
      return tempFile.changeFileNameOnly(file.name);
    }
    return tempFile.changeFileNameOnlySafe(file.name);
  }

  Future<int> writeTo(StreamController<Uint8List> out) {
    var length = 0;
    var completer = Completer<int>();

    void addToSink(Map<String, dynamic> chunk) {
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

  /// Removes this document from the bucket
  Future<void> delete() async {
    await fs.files.deleteOne(where.id(id));
    await fs.chunks.deleteMany(where.eq('files_id', id));
  }
}
