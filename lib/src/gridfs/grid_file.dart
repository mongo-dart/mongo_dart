part of mongo_dart;

class GridFSFile {
  GridFS fs = null;
  var id;
  String filename;
  String contentType;
  int length;
  int chunkSize;
  Date uploadDate;
  Map<String, Object> extraData;
  String md5;

  void save() {
    if (fs == null) {
      throw "Need fs";
    }
    fs.files.save(data);
  }

  void validate() {
    if (fs == null)
      throw "no fs";
    if (md5 == null)
      throw "no md5 stored";

    // query for md5 at filemd5
    // see if the md5s are the same
    // throw an error if they are not
  }

  int numChunks() {
    return (length.toDouble() / chunkSize).ceil().toInt();
  }

  List<String> get aliases {
    return extraData["aliases"];
  }

  Map get metaData {
    return extraData["metadata"];
  }
  
  set metaData(Map metaData) {
    extraData["metadata"] = metaData;
  }

  Map get data {
    return {
      "_id" : id,
      "filename" : filename,
      "contentType" : contentType,
      "length" : length,
      "chunkSize" : chunkSize,
      "uploadDate" : uploadDate,
      "md5" : md5,
      // TODO(tsander): Extra Data?? Meta Data??
    };
  }

  void setGridFS( GridFS fs ) {
    this.fs = fs;
  }
}