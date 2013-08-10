library gridfs_tests;
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:path/path.dart' as path;

const DefaultUri = 'mongodb://127.0.0.1/';

class MockConsumer<S> implements StreamConsumer<S> {
  List<S> data = <S>[];
  Future consume(Stream<S> stream) {
    var completer = new Completer();
    stream.listen(_onData, onDone: () => completer.complete(null));
    return completer.future;
  }
  _onData(chunk) {
    data.addAll(chunk);
  }
  Future addStream(Stream<S> stream) {
    var completer = new Completer();
    stream.listen(_onData, onDone: () => completer.complete(null));
    return completer.future;
  }  
  Future close() {
  }   
}
clearFSCollections(GridFS gridFS) {
  gridFS.files.remove();
  gridFS.chunks.remove();
}
Future testSmall(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c){
    List<int> data = [0x00, 0x01, 0x10, 0x11, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff];
    GridFS gridFS = new GridFS(db);
    clearFSCollections(gridFS);
    return testInOut(data, gridFS);
  }).then((c){
    db.close();
  });
}

Future testBig(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c){
    List<int> smallData = [0x00, 0x01, 0x10, 0x11, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff];

    int target = GridFS.DEFAULT_CHUNKSIZE * 3;
    List<int> data = new List();
    while (data.length < target) {
      data.addAll(smallData);
    }
    GridFS gridFS = new GridFS(db);
    clearFSCollections(gridFS);
    return testInOut(data, gridFS);
  }).then((c){
    db.close();
  });
}

Future tesSomeChunks(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c){
    List<int> smallData = [0x00, 0x01, 0x10, 0x11, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff];
    GridFS.DEFAULT_CHUNKSIZE = 9;
    int target = GridFS.DEFAULT_CHUNKSIZE * 3;
    List<int> data = new List();
    while (data.length < target) {
      data.addAll(smallData);
    }
    GridFS gridFS = new GridFS(db);
    clearFSCollections(gridFS);
    return testInOut(data, gridFS);
  }).then((c){
    db.close();
  });
}
Future testInOut(List<int> data, GridFS gridFS, [Map extraData = null]) {
  var consumer = new MockConsumer();
  var out = new IOSink(consumer);
  return getInitialState(gridFS).then((List<int> initialState){    
    var inputStream = new Stream.fromIterable([data]);
    GridIn input = gridFS.createFile(inputStream, "test");
    if (extraData != null) {
      input.extraData = extraData;
    }
    return input.save().then((c) {
      return gridFS.findOne(where.eq("_id", input.id)).then((GridOut gridOut) {
        expect(gridOut,isNotNull, reason: "Did not find file by Id");
        expect(input.id, gridOut.id, reason: "Ids not equal.");
        expect(GridFS.DEFAULT_CHUNKSIZE, gridOut.chunkSize, reason: "Chunk size not the same.");
        expect("test", gridOut.filename, reason: "Filename not equal");
        expect(input.extraData, gridOut.extraData);
        return gridOut.writeTo(out);
      }).then((c){
        expect(data, orderedEquals(consumer.data));
        return getInitialState(gridFS);
      });
    });
  });
}

Future<List<int>> getInitialState(GridFS gridFS) {
  Completer completer = new Completer();
  List<Future<int>> futures = new List();
  futures.add(gridFS.files.count());
  futures.add(gridFS.chunks.count());
  Future.wait(futures).then((List<double> futureResults) {
    List<int> result = new List<int>(2);
    result[0] = futureResults[0].toInt();
    result[1] = futureResults[1].toInt();
    completer.complete(result);
  });
  return completer.future;
}

Future testChunkTransformerOneChunk(){
  return new Stream.fromIterable([[1,2,3,4,5,6,7,8,9,10,11]]).transform(new ChunkTransformer(3))
  .toList().then((chunkedList){    
    expect(chunkedList[0],orderedEquals([1,2,3]));
    expect(chunkedList[1],orderedEquals([4,5,6]));
    expect(chunkedList[2],orderedEquals([7,8,9]));
    expect(chunkedList[3],orderedEquals([10,11]));    
  });    
}
Future testChunkTransformerSeveralChunks(){
  return new Stream.fromIterable([[1,2,3,4],[5],[6,7],[8,9,10,11]]).transform(new ChunkTransformer(3))
  .toList().then((chunkedList){
    expect(chunkedList[0],orderedEquals([1,2,3]));
    expect(chunkedList[1],orderedEquals([4,5,6]));
    expect(chunkedList[2],orderedEquals([7,8,9]));
    expect(chunkedList[3],orderedEquals([10,11]));    
  });
}

Future testFileToGridFSToFile() {
  GridFS.DEFAULT_CHUNKSIZE = 30;  
  GridIn input;
  String dir = path.dirname(new Options().script);
  var inputStream = new File('$dir/gridfs_testdata_in.txt').openRead();
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c){
    var gridFS = new GridFS(db);
    clearFSCollections(gridFS);
    input = gridFS.createFile(inputStream, "test");  
    return input.save();
  }).then((c) { 
    var gridFS = new GridFS(db);
    return gridFS.getFile('test');
  }).then((GridOut gridOut) {   
    return gridOut.writeToFilename('$dir/gridfs_testdata_out.txt');
  }).then((c){
    List<int> dataIn = new File('$dir/gridfs_testdata_in.txt').readAsBytesSync();
    List<int> dataOut = new File('$dir/gridfs_testdata_out.txt').readAsBytesSync();
    expect(dataOut, orderedEquals(dataIn));
    db.close();
  });
}

Future testExtraData() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  return db.open().then((c){
    List<int> data = [0x00, 0x01, 0x10, 0x11, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff];
    GridFS gridFS = new GridFS(db);
    clearFSCollections(gridFS);
    Map extraData = {
      "test" : [1,2,3],
      "extraData" : "Test",
      "map" : {
        "a" : 1
      }
    };
    return testInOut(data, gridFS, extraData);
  }).then((c){
    db.close();
  });
}

main(){
  group('ChunkTransformer tests:', (){    
    test('testChunkTransformer',testChunkTransformerOneChunk);
    test('testChunkTransformerSeveralChunks',testChunkTransformerSeveralChunks);    
  });    
  group('GridFS tests:', (){
    setUp(() => GridFS.DEFAULT_CHUNKSIZE = 256 * 1024);
    test('testSmall',testSmall);
    test('tesSomeChunks',tesSomeChunks);    
    test('testBig',testBig);
    test('testFileToGridFSToFile',testFileToGridFSToFile);
    test('testExtraData', testExtraData);
  });
}