library database_tests;
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:uri';
import 'dart:io';
import 'dart:crypto';
import 'package:unittest/unittest.dart';

const DefaultUri = 'mongodb://127.0.0.1/';

testSmall(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().chain(expectAsync1((c){
    List<int> data = [0x00, 0x01, 0x10, 0x11, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff];
    
    GridFS gridFS = new GridFS(db);
    return testInOut(data, gridFS);
  })).then((c){
    db.close();
  });
}

testBig(){
  Db db = new Db('${DefaultUri}mongo_dart-test');
  db.open().chain(expectAsync1((c){
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
  return getInitialState(gridFS).chain(expectAsync1((List<int> initialState){
    ListInputStream inputStream = new ListInputStream();
    inputStream.write(data);
    inputStream.markEndOfStream();
    GridIn input = gridFS.createFile(inputStream, "test");
    return input.save().chain(expectAsync1((c) {
      return gridFS.findOne(where.eq("_id", input.id)).chain(expectAsync1((GridOut gridOut) {
        Expect.isNotNull(gridOut, "Did not find file by Id");
        Expect.equals(input.id, gridOut.id, "Ids not equal.");
        Expect.equals(GridFS.DEFAULT_CHUNKSIZE, gridOut.chunkSize, "Chunk size not the same.");
        Expect.equals("test", gridOut.filename, "Filename not equal");
        
        return gridOut.writeTo(out);
      })).chain(expectAsync1((c){
        Expect.listEquals(data, out.read());
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
  Futures.wait(futures).then((List<double> futureResults) {
    List<int> result = new List<int>(2);
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