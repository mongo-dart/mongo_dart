part of mongo_dart;

class GridFSFile {
  GridFS fs = null;
  var id;
  String filename;
  String contentType;
  int length;
  int chunkSize;
  DateTime uploadDate;
  Map<String, Object> extraData;
  StringBuffer fullContent;
  String md5;

  GridFSFile([Map<String, dynamic> data = const {}]) {
    this.data = data;
  }

  Future<Map<String, dynamic>> save() {
    if (fs == null) {
      throw MongoDartError('Need fs');
    }
    Map<String, dynamic> tempData = data;
    return fs.files.insert(tempData);
  }

  Future<bool> validate() {
    if (fs == null) {
      throw MongoDartError('no fs');
    }
    if (md5 == null) {
      throw MongoDartError('no md5 stored');
    }

    var completer = Completer<bool>();
    // query for md5 at filemd5
    DbCommand dbCommand = DbCommand(
        fs.database, fs.bucketName, 0, 0, 1, {"filemd5": id}, {"md5": 1});
    fs.database.executeDbCommand(dbCommand).then((data) {
      if (data != null && data.containsKey("md5")) {
        completer.complete(md5 == data["md5"]);
      } else {
        completer.complete(false);
      }
    });
    return completer.future;
  }

  int numChunks() {
    return (length.toDouble() / chunkSize).ceil().toInt();
  }

  List<String> get aliases {
    return extraData["aliases"] as List<String>;
  }

  Map<String, dynamic> get metaData {
    return extraData["metadata"] as Map<String, dynamic>;
  }

  set metaData(Map<String, dynamic> metaData) {
    extraData['metadata'] = metaData;
  }

  Map<String, dynamic> get data {
    var result = <String, dynamic>{
      '_id': id,
      'filename': filename,
      'contentType': contentType,
      'length': length,
      'chunkSize': chunkSize,
      'uploadDate': uploadDate,
      'md5': md5,
    };
    extraData.forEach((String key, Object value) {
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
    length = extraData.remove('length') as int;
    chunkSize = extraData.remove('chunkSize') as int;
    uploadDate = extraData.remove('uploadDate') as DateTime;
    md5 = extraData.remove('md5')?.toString();
  }

  void setGridFS(GridFS fs) {
    this.fs = fs;
  }
}
