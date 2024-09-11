import 'dart:async';
import 'package:universal_io/io.dart';

import 'package:mongo_dart/mongo_dart.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

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

void main() async {
  var db = Db(defaultUri);
  await db.open();

  Future cleanupDatabase() async {
    await db.close();
  }

  if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
    return;
  }

  var collectionName = 'delete-gridfs';
  var gridFS = GridFS(db, collectionName);
  await gridFS.dropBucket();

  // **** data preparation
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

  // Set small chunks
  // This is normally don't needed. The default chunkSize is fine.
  // But we want to split are small data set into more than one chunks
  GridFS.defaultChunkSize = 9;

  // assures at least 3 chunks (for our tine test data set)
  var target = GridFS.defaultChunkSize * 3;
  var data = <int>[];
  while (data.length < target) {
    data.addAll(smallData);
  }
  print('Expected chunks: ${(data.length / GridFS.defaultChunkSize).ceil()}');
  var extraData = <String, dynamic>{
    'test': [1, 2, 3],
    'extraData': 'Test',
    'map': {'a': 1}
  };

  var inputStream = Stream.fromIterable([data]);
  var input = gridFS.createFile(inputStream, 'test');
  input.extraData = extraData;
  await input.save();

  var gridOut = await gridFS.findOne(where.eq('_id', input.id));
  var consumer = MockConsumer();
  var out = IOSink(consumer);
  await gridOut?.writeTo(out);

  await gridOut?.delete();

  print('Out Chunk size: ${gridOut?.chunkSize}'); // 9
  print('Out Chunk lengt: ${gridOut?.length}');
  print('Out Chunk num: ${gridOut?.numChunks()}');

  await cleanupDatabase();
}
