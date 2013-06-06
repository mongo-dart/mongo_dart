library gridfs_tests;
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:async';
import 'package:unittest/unittest.dart';

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
testSmall(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().then(expectAsync1((c){
    List<int> data = [0x00, 0x01, 0x10, 0x11, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff];
    GridFS gridFS = new GridFS(db);
    clearFSCollections(gridFS);
    return testInOut(data, gridFS);
  })).then((c){
    db.close();
  });
}

testBig(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().then(expectAsync1((c){
    List<int> smallData = [0x00, 0x01, 0x10, 0x11, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff];

    int target = GridFS.DEFAULT_CHUNKSIZE * 3;
    List<int> data = new List();
    while (data.length < target) {
      data.addAll(smallData);
    }
    GridFS gridFS = new GridFS(db);
    clearFSCollections(gridFS);
    return testInOut(data, gridFS);
  })).then((c){
    db.close();
  });
}

tesSomeChunks(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().then(expectAsync1((c){
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
  })).then((c){
    db.close();
  });
}
Future testInOut(List<int> data, GridFS gridFS, [Map extraData = null]) {
  var consumer = new MockConsumer();
  var out = new IOSink(consumer);
  return getInitialState(gridFS).then(expectAsync1((List<int> initialState){    
    var inputStream = new Stream.fromIterable([data]);
    GridIn input = gridFS.createFile(inputStream, "test");
    if (extraData != null) {
      input.extraData = extraData;
    }
    return input.save().then(expectAsync1((c) {
      return gridFS.findOne(where.eq("_id", input.id)).then(expectAsync1((GridOut gridOut) {
        expect(gridOut,isNotNull, reason: "Did not find file by Id");
        expect(input.id, gridOut.id, reason: "Ids not equal.");
        expect(GridFS.DEFAULT_CHUNKSIZE, gridOut.chunkSize, reason: "Chunk size not the same.");
        expect("test", gridOut.filename, reason: "Filename not equal");
        expect(input.extraData, gridOut.extraData);
        return gridOut.writeTo(out);
      })).then(expectAsync1((c){
        expect(data, orderedEquals(consumer.data));
        return getInitialState(gridFS);
      }));
    }));
  }));
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

testChunkTransformerOneChunk(){
  new Stream.fromIterable([[1,2,3,4,5,6,7,8,9,10,11]]).transform(new ChunkTransformer(3))
  .toList().then(expectAsync1((chunkedList){    
    expect(chunkedList[0],orderedEquals([1,2,3]));
    expect(chunkedList[1],orderedEquals([4,5,6]));
    expect(chunkedList[2],orderedEquals([7,8,9]));
    expect(chunkedList[3],orderedEquals([10,11]));    
  }));    
}
testChunkTransformerSeveralChunks(){
  new Stream.fromIterable([[1,2,3,4],[5],[6,7],[8,9,10,11]]).transform(new ChunkTransformer(3))
  .toList().then(expectAsync1((chunkedList){    
    expect(chunkedList[0],orderedEquals([1,2,3]));
    expect(chunkedList[1],orderedEquals([4,5,6]));
    expect(chunkedList[2],orderedEquals([7,8,9]));
    expect(chunkedList[3],orderedEquals([10,11]));    
  }));    
}

testFileToGridFSToFile() {
  GridFS.DEFAULT_CHUNKSIZE = 30;  
  GridIn input;
  var path = new Path(new Options().script).directoryPath;
  var inputStream = new File('gridfs_testdata_in.txt').openRead();
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().then(expectAsync1((c){
    var gridFS = new GridFS(db);
    clearFSCollections(gridFS);
    input = gridFS.createFile(inputStream, "test");  
    return input.save();
  })).then(expectAsync1((c) { 
    var gridFS = new GridFS(db);
    return gridFS.getFile('test');
  })).then(expectAsync1((GridOut gridOut) {   
    return gridOut.writeToFilename('gridfs_testdata_out.txt');
  })).then(expectAsync1((c){
    List<int> dataIn = new File('gridfs_testdata_in.txt').readAsBytesSync();
    List<int> dataOut = new File('gridfs_testdata_out.txt').readAsBytesSync();      
    expect(dataOut, orderedEquals(dataIn));
    db.close();
  }));
}

testExtraData() {
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().then(expectAsync1((c){
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
  })).then((c){
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