library gridfs_tests;

import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io';
import 'dart:async';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

const dbName = 'testauth';
const DefaultUri = 'mongodb://localhost:27017/test-mongo-dart';
Db db;

Uuid uuid = new Uuid();
List<String> usedCollectionNames = [];

String getRandomCollectionName() {
  String name = uuid.v4();
  usedCollectionNames.add(name);
  return name;
}

class MockConsumer implements StreamConsumer<List<int>> {
  List<int> data = [];

  Future consume(Stream<List<int>> stream) {
    var completer = new Completer();
    stream.listen(_onData, onDone: () => completer.complete(null));
    return completer.future;
  }

  _onData(List<int> chunk) {
    data.addAll(chunk);
  }

  Future addStream(Stream<List<int>> stream) {
    var completer = new Completer();
    stream.listen(_onData, onDone: () => completer.complete(null));
    return completer.future;
  }

  Future close() => new Future.value(true);
}

clearFSCollections(GridFS gridFS) {
  gridFS.files.remove({});
  gridFS.chunks.remove({});
}

Future testSmall() async {
  String collectionName = getRandomCollectionName();

  List<int> data = [0x00, 0x01, 0x10, 0x11, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff];
  GridFS gridFS = new GridFS(db, collectionName);
  clearFSCollections(gridFS);
  await testInOut(data, gridFS);
}

Future testBig() {
  String collectionName = getRandomCollectionName();
  List<int> smallData = [
    0x00,
    0x01,
    0x10,
    0x11,
    0x7e,
    0x7f,
    0x80,
    0x81,
    0xfe,
    0xff
  ];

  int target = GridFS.DEFAULT_CHUNKSIZE * 3;
  List<int> data = new List();
  while (data.length < target) {
    data.addAll(smallData);
  }
  GridFS gridFS = new GridFS(db, collectionName);
  clearFSCollections(gridFS);
  return testInOut(data, gridFS);
}

Future tesSomeChunks() async {
  String collectionName = getRandomCollectionName();
  List<int> smallData = [
    0x00,
    0x01,
    0x10,
    0x11,
    0x7e,
    0x7f,
    0x80,
    0x81,
    0xfe,
    0xff
  ];

  GridFS.DEFAULT_CHUNKSIZE = 9;
  int target = GridFS.DEFAULT_CHUNKSIZE * 3;

  List<int> data = new List();
  while (data.length < target) {
    data.addAll(smallData);
  }

  GridFS gridFS = new GridFS(db, collectionName);
  clearFSCollections(gridFS);

  return testInOut(data, gridFS);
}

Future<List<int>> getInitialState(GridFS gridFS) {
  Completer completer = new Completer();
  List<Future<int>> futures = new List();
  futures.add(gridFS.files.count());
  futures.add(gridFS.chunks.count());
  Future.wait(futures).then((List<int> futureResults) {
    List<int> result = new List<int>(2);
    result[0] = futureResults[0].toInt();
    result[1] = futureResults[1].toInt();
    completer.complete(result);
  });
  return completer.future;
}

Future testInOut(List<int> data, GridFS gridFS, [Map extraData = null]) async {
  var consumer = new MockConsumer();
  var out = new IOSink(consumer);
  await getInitialState(gridFS);
  var inputStream = new Stream.fromIterable([data]);
  GridIn input = gridFS.createFile(inputStream, "test");
  if (extraData != null) {
    input.extraData = extraData;
    await input.save();
    GridOut gridOut = await gridFS.findOne(where.eq("_id", input.id));
    expect(gridOut, isNotNull, reason: "Did not find file by Id");
    expect(input.id, gridOut.id, reason: "Ids not equal.");
    expect(GridFS.DEFAULT_CHUNKSIZE, gridOut.chunkSize,
        reason: "Chunk size not the same.");
    expect("test", gridOut.filename, reason: "Filename not equal");
    expect(input.extraData, gridOut.extraData);
    await gridOut.writeTo(out);
    expect(consumer.data, orderedEquals(data));
  }
}

Future testChunkTransformerOneChunk() {
  return new Stream.fromIterable([
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
  ]).transform(new ChunkHandler(3).transformer).toList().then((chunkedList) {
    expect(chunkedList[0], orderedEquals([1, 2, 3]));
    expect(chunkedList[1], orderedEquals([4, 5, 6]));
    expect(chunkedList[2], orderedEquals([7, 8, 9]));
    expect(chunkedList[3], orderedEquals([10, 11]));
  });
}

Future testChunkTransformerSeveralChunks() {
  return new Stream.fromIterable([
    [1, 2, 3, 4],
    [5],
    [6, 7],
    [8, 9, 10, 11]
  ]).transform(new ChunkHandler(3).transformer).toList().then((chunkedList) {
    expect(chunkedList[0], orderedEquals([1, 2, 3]));
    expect(chunkedList[1], orderedEquals([4, 5, 6]));
    expect(chunkedList[2], orderedEquals([7, 8, 9]));
    expect(chunkedList[3], orderedEquals([10, 11]));
  });
}

Future testFileToGridFSToFile() async {
  String collectionName = getRandomCollectionName();
  GridFS.DEFAULT_CHUNKSIZE = 30;
  GridIn input;
  String dir = path.join(path.current, 'test');

  var inputStream = new File('$dir/gridfs_testdata_in.txt').openRead();

  var gridFS = new GridFS(db, collectionName);
  clearFSCollections(gridFS);

  input = gridFS.createFile(inputStream, "test");
  await input.save();

  gridFS = new GridFS(db, collectionName);
  var gridOut = await gridFS.getFile('test');
  await gridOut.writeToFilename('$dir/gridfs_testdata_out.txt');

  List<int> dataIn = new File('$dir/gridfs_testdata_in.txt').readAsBytesSync();
  List<int> dataOut =
      new File('$dir/gridfs_testdata_out.txt').readAsBytesSync();

  expect(dataOut, orderedEquals(dataIn));
}

Future testExtraData() {
  String collectionName = getRandomCollectionName();

  List<int> data = [0x00, 0x01, 0x10, 0x11, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff];
  GridFS gridFS = new GridFS(db, collectionName);
  clearFSCollections(gridFS);
  Map extraData = {
    "test": [1, 2, 3],
    "extraData": "Test",
    "map": {"a": 1}
  };

  return testInOut(data, gridFS, extraData);
}

main() {
  Future initializeDatabase() async {
    db = new Db(DefaultUri);
    await db.open();
  }

  Future cleanupDatabase() async {
    await db.close();
  }

  setUp(() async {
    await initializeDatabase();
  });

  tearDown(() async {
    await cleanupDatabase();
  });

  group('ChunkTransformer tests:', () {
    test('testChunkTransformer', testChunkTransformerOneChunk);
    test(
        'testChunkTransformerSeveralChunks', testChunkTransformerSeveralChunks);
  });
  group('GridFS tests:', () {
    setUp(() => GridFS.DEFAULT_CHUNKSIZE = 256 * 1024);
    test('testSmall', testSmall);
    test('tesSomeChunks', tesSomeChunks);
    test('testBig', testBig);
    test('testFileToGridFSToFile', testFileToGridFSToFile);
    test('testExtraData', testExtraData);
  });

  tearDownAll(() async {
    await db.open();
    await Future.forEach(usedCollectionNames,
        (String collectionName) => db.collection(collectionName).drop());
    await db.close();
  });
}
