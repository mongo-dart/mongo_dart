library gridfs_tests;
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:uri';
import 'dart:io';
import 'dart:crypto';
import 'dart:async';
import 'package:unittest/unittest.dart';

const DefaultUri = 'mongodb://127.0.0.1/';

testSmall(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().then(expectAsync1((c){
    List<int> data = [0x00, 0x01, 0x10, 0x11, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff];

    GridFS gridFS = new GridFS(db);
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
    return testInOut(data, gridFS);
  })).then((c){
    db.close();
  });
}

Future testInOut(List<int> data, GridFS gridFS) {
  ListOutputStream out = new ListOutputStream();
  return getInitialState(gridFS).then(expectAsync1((List<int> initialState){
    ListInputStream inputStream = new ListInputStream();
    inputStream.write(data);
    inputStream.markEndOfStream();
    GridIn input = gridFS.createFile(inputStream, "test");
    return input.save().then(expectAsync1((c) {
      return gridFS.findOne(where.eq("_id", input.id)).then(expectAsync1((GridOut gridOut) {
        expect(gridOut,isNotNull, reason: "Did not find file by Id");
        expect(input.id, gridOut.id, reason: "Ids not equal.");
        expect(GridFS.DEFAULT_CHUNKSIZE, gridOut.chunkSize, reason: "Chunk size not the same.");
        expect("test", gridOut.filename, reason: "Filename not equal");

        return gridOut.writeTo(out);
      })).then(expectAsync1((c){
        expect(data, orderedEquals(out.read()));
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
    List<int> result = new List<int>.fixedLength(2);
    result[0] = futureResults[0].toInt();
    result[1] = futureResults[1].toInt();
    completer.complete(result);
  });
  return completer.future;
}

main(){
  initBsonPlatform();
  group('GridFS tests:', (){
    test('testSmall',testSmall);
    test('testBig',testBig);
  });
}