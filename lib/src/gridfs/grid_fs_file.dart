part of mongo_dart;

abstract class GridFSFile {
  GridFS fs;
  dynamic id;
  String? filename;
  String? contentType;
  int? length;
  int chunkSize = GridFS.defaultChunkSize;
  DateTime? uploadDate;
  Map<String, dynamic> extraData = <String, dynamic>{};
  //StringBuffer fullContent;
  String? md5;

  GridFSFile(this.fs, [Map<String, dynamic>? data]) {
    this.data = data ?? {};
  }

  Future<Map<String, dynamic>> save() async {
    //if (fs == null) {
    //  throw MongoDartError('Need fs');
    //}
    var tempData = data;
    // TODO update this
    var (_, retValue, _, _) = await fs.files.insertOne(tempData);
    return retValue;
  }

  Future<bool> validate() {
    //if (fs == null) {
    //  throw MongoDartError('no fs');
    //}
    if (md5 == null) {
      throw MongoDartError('no md5 stored');
    }

    var completer = Completer<bool>();
    // query for md5 at filemd5
    // Todo toe checked
    /* var dbCommand = DbCommand(
        fs.database, fs.bucketName, 0, 0, 1, {'filemd5': id}, {'md5': 1});
    fs.database.executeDbCommand(dbCommand).then((data) {
      if (data.containsKey('md5')) {
        completer.complete(md5 == data['md5']);
      } else {
        completer.complete(false);
      }
    }); */
    return completer.future;
  }

  int numChunks() => ((length ?? 0.0) / chunkSize).ceil();

  List<String> get aliases => extraData['aliases'] as List<String>;

  Map<String, dynamic> get metaData =>
      extraData['metadata'] as Map<String, dynamic>;
  set metaData(Map<String, dynamic> metaData) =>
      extraData['metadata'] = metaData;

  Map<String, dynamic> get data {
    var result = <String, dynamic>{
      '_id': id,
      'length': length,
      'chunkSize': chunkSize,
      'uploadDate': uploadDate,
      //'md5': md5,
      'filename': filename,
      'contentType': contentType,
    };
    extraData.forEach((String key, Object? value) {
      result[key] = value;
    });
    return result;
  }

  set data(Map<String, dynamic> input) {
    extraData = Map.from(input);

    // Remove the known keys. Leaving the extraData.
    id = extraData.remove('_id');
    filename = extraData.remove('filename')?.toString();
    contentType = extraData.remove('contentType')?.toString();
    length = extraData.remove('length') as int?;
    chunkSize =
        extraData.remove('chunkSize') as int? ?? GridFS.defaultChunkSize;
    uploadDate = extraData.remove('uploadDate') as DateTime?;
    md5 = extraData.remove('md5')?.toString();
  }

  //void setGridFS(GridFS fs) => this.fs = fs;
}
