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

Uuid uuid = Uuid();
List<String> usedCollectionNames = [];

String getRandomCollectionName() {
  var name = uuid.v4();
  usedCollectionNames.add(name);
  return name;
}

class MockConsumer implements StreamConsumer<List<int>> {
  List<int> data = [];

  Future consume(Stream<List<int>> stream) {
    var completer = Completer();
    stream.listen(_onData, onDone: () => completer.complete(null));
    return completer.future;
  }

  void _onData(List<int> chunk) {
    data.addAll(chunk);
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    var completer = Completer();
    stream.listen(_onData, onDone: () => completer.complete(null));
    return completer.future;
  }

  @override
  Future close() => Future.value(true);
}

void clearFSCollections(GridFS gridFS) {
  gridFS.files.remove(<String, dynamic>{});
  gridFS.chunks.remove(<String, dynamic>{});
}

Future testSmall() async {
  var collectionName = getRandomCollectionName();

  var data = <int>[0x00, 0x01, 0x10, 0x11, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff];
  var gridFS = GridFS(db, collectionName);
  clearFSCollections(gridFS);
  await testInOut(data, gridFS);
}

Future testBig() {
  var collectionName = getRandomCollectionName();
  var smallData = <int>[
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

  var target = GridFS.DEFAULT_CHUNKSIZE * 3;
  var data = <int>[];
  while (data.length < target) {
    data.addAll(smallData);
  }
  var gridFS = GridFS(db, collectionName);
  clearFSCollections(gridFS);
  return testInOut(data, gridFS);
}

Future tesSomeChunks() async {
  var collectionName = getRandomCollectionName();
  var smallData = <int>[
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
  var target = GridFS.DEFAULT_CHUNKSIZE * 3;

  var data = <int>[];
  while (data.length < target) {
    data.addAll(smallData);
  }

  var gridFS = GridFS(db, collectionName);
  clearFSCollections(gridFS);

  return testInOut(data, gridFS);
}

Future<List<int>> getInitialState(GridFS gridFS) {
  var completer = Completer<List<int>>();
  var futures = <Future<int>>[];
  futures.add(gridFS.files.count());
  futures.add(gridFS.chunks.count());
  Future.wait(futures).then((List<int> futureResults) {
    var result = List<int>(2);
    result[0] = futureResults[0].toInt();
    result[1] = futureResults[1].toInt();
    completer.complete(result);
  });
  return completer.future;
}

Future testInOut(List<int> data, GridFS gridFS,
    [Map<String, dynamic> extraData]) async {
  var consumer = MockConsumer();
  var out = IOSink(consumer);
  await getInitialState(gridFS);
  var inputStream = Stream.fromIterable([data]);
  var input = gridFS.createFile(inputStream, 'test');
  if (extraData != null) {
    input.extraData = extraData;
    await input.save();
    var gridOut = await gridFS.findOne(where.eq('_id', input.id));
    expect(gridOut, isNotNull, reason: 'Did not find file by Id');
    expect(input.id, gridOut.id, reason: 'Ids not equal.');
    expect(GridFS.DEFAULT_CHUNKSIZE, gridOut.chunkSize,
        reason: 'Chunk size not the same.');
    expect('test', gridOut.filename, reason: 'Filename not equal');
    expect(input.extraData, gridOut.extraData);
    await gridOut.writeTo(out);
    expect(consumer.data, orderedEquals(data));
  }
}

Future testChunkTransformerOneChunk() {
  return Stream.fromIterable([
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
  ]).transform(ChunkHandler(3).transformer).toList().then((chunkedList) {
    expect(chunkedList[0], orderedEquals([1, 2, 3]));
    expect(chunkedList[1], orderedEquals([4, 5, 6]));
    expect(chunkedList[2], orderedEquals([7, 8, 9]));
    expect(chunkedList[3], orderedEquals([10, 11]));
  });
}

Future testChunkTransformerSeveralChunks() {
  return Stream.fromIterable([
    [1, 2, 3, 4],
    [5],
    [6, 7],
    [8, 9, 10, 11]
  ]).transform(ChunkHandler(3).transformer).toList().then((chunkedList) {
    expect(chunkedList[0], orderedEquals([1, 2, 3]));
    expect(chunkedList[1], orderedEquals([4, 5, 6]));
    expect(chunkedList[2], orderedEquals([7, 8, 9]));
    expect(chunkedList[3], orderedEquals([10, 11]));
  });
}

Future testFileToGridFSToFile() async {
  var collectionName = getRandomCollectionName();
  GridFS.DEFAULT_CHUNKSIZE = 30;
  GridIn input;
  var dir = path.join(path.current, 'test');

  var inputStream = File('$dir/gridfs_testdata_in.txt').openRead();

  var gridFS = GridFS(db, collectionName);
  clearFSCollections(gridFS);

  input = gridFS.createFile(inputStream, 'test');
  await input.save();

  gridFS = GridFS(db, collectionName);
  var gridOut = await gridFS.getFile('test');
  await gridOut.writeToFilename('$dir/gridfs_testdata_out.txt');

  List<int> dataIn = File('$dir/gridfs_testdata_in.txt').readAsBytesSync();
  List<int> dataOut = File('$dir/gridfs_testdata_out.txt').readAsBytesSync();

  expect(dataOut, orderedEquals(dataIn));
}

Future testExtraData() {
  var collectionName = getRandomCollectionName();

  var data = <int>[0x00, 0x01, 0x10, 0x11, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff];
  var gridFS = GridFS(db, collectionName);
  clearFSCollections(gridFS);
  var extraData = <String, dynamic>{
    'test': [1, 2, 3],
    'extraData': 'Test',
    'map': {'a': 1}
  };

  return testInOut(data, gridFS, extraData);
}

void main() {
  Future initializeDatabase() async {
    db = Db(DefaultUri);
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
