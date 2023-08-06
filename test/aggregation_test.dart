import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/command/query_and_write_operation_commands/update_operation/base/update_union.dart';
import 'package:mongo_dart/src/unions/query_union.dart';
import 'package:test/test.dart';

const dbName = 'test-mongo-dart';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

late MongoClient client;
late MongoDatabase db;
Uuid uuid = Uuid();
List<String> usedCollectionNames = [];

String getRandomCollectionName() {
  var name = uuid.v4();
  usedCollectionNames.add(name);
  return name;
}

void main() async {
  Future initializeDatabase() async {
    client = MongoClient(defaultUri);
    print('Client OK');
    await client.connect();
    db = client.db();
  }

  Future cleanupDatabase() async {
    print('Close client');
    await client.close();
  }

  group('Aggregation', () {
    //var cannotRunTests = false;
    //var running4_4orGreater = false;
    var running4_2orGreater = false;
    var running4_2 = false;

    //var isReplicaSet = false;
    //var isStandalone = false;
    var isSharded = false;
    setUp(() async {
      await initializeDatabase();

      var serverFcv = db.server.serverCapabilities.fcv;
      if (serverFcv?.compareTo('4.4') != -1) {
        //running4_4orGreater = true;
      }
      if (serverFcv?.compareTo('4.2') != -1) {
        running4_2orGreater = true;
      }
      if (serverFcv?.compareTo('4.2') == 0) {
        running4_2 = true;
      }
      //isReplicaSet = db.server.serverCapabilities.isReplicaSet;
      //isStandalone = db.server.serverCapabilities.isStandalone;
      isSharded = db.server.serverCapabilities.isShardedCluster;
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    group('Stages', () {
      test(r'Raw $set $unset on operation', () async {
        if (!running4_2orGreater) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var (ret, _, _, _) = await collection.insertMany([
          {
            '_id': 1,
            'member': 'abc123',
            'status': 'A',
            'points': 2,
            'misc1': 'note to self: confirm status',
            'misc2': 'Need to activate'
          },
          {
            '_id': 2,
            'member': 'xyz123',
            'status': 'A',
            'points': 60,
            'misc1': 'reminder: ping me at 100pts',
            'misc2': 'Some random comment'
          },
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var updateOperation = UpdateOperation(
            collection,
            [
              UpdateStatement(
                  QueryUnion(<String, Object>{}),
                  UpdateUnion([
                    {
                      r'$set': {
                        'status': 'Modified',
                        'comments': [r'$misc1', r'$misc2'],
                        'more': null
                      }
                    },
                    {
                      r'$unset': ['misc1', 'misc2']
                    }
                  ]),
                  multi: true)
            ],
            ordered: false,
            updateOptions: UpdateOptions(
                writeConcern: WriteConcern(w: wMajority, wtimeout: 5000)));
        var res = await updateOperation.process();

        expect(res, isNotNull);
        expect(res[keyOk], 1.0);
        expect(res[keyN], 2);
        expect(res[keyNModified], 2);
        var retFind = await collection.findOne(where.eq('_id', 1));
        expect(retFind?.containsKey('more'), isTrue);
        expect(retFind?['more'], isNull);

        updateOperation = UpdateOperation(
            collection,
            [
              UpdateStatement(
                  QueryUnion(<String, Object>{}),
                  UpdateUnion(AggregationPipelineBuilder()
                      .addStage(SetStage({'more2': BsonNull()}))
                      .addStage(Unset(['more']))),
                  multi: true)
            ],
            ordered: false,
            updateOptions: UpdateOptions(
                writeConcern: WriteConcern(w: wMajority, wtimeout: 5000)));
        res = await updateOperation.process();

        expect(res, isNotNull);
        expect(res[keyOk], 1.0);
        expect(res[keyN], 2);
        expect(res[keyNModified], 2);
        retFind = await collection.findOne(where.eq('_id', 1));
        expect(retFind?.containsKey('more'), isFalse);
        expect(retFind?.containsKey('more2'), isTrue);
        expect(retFind?['more2'], isNull);
      });

      test(r'$set advanced on operation', () async {
        if (!running4_2orGreater) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var (ret, _, _, _) = await collection.insertMany([
          {
            '_id': 1,
            'tests': [95, 92, 90]
          },
          {
            '_id': 2,
            'tests': [94, 88, 90]
          },
          {
            '_id': 3,
            'tests': [70, 75, 82]
          }
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var updateOperation = UpdateOperation(
            collection,
            [
              UpdateStatement(
                  QueryUnion(<String, Object>{}),
                  UpdateUnion([
                    {
                      r'$set': {
                        'average': {r'$avg': r'$tests'}
                      }
                    },
                    {
                      r'$set': {
                        'grade': {
                          r'$switch': {
                            'branches': [
                              {
                                'case': {
                                  r'$gte': [r'$average', 90]
                                },
                                'then': 'A'
                              },
                              {
                                'case': {
                                  r'$gte': [r'$average', 80]
                                },
                                'then': 'B'
                              },
                              {
                                'case': {
                                  r'$gte': [r'$average', 70]
                                },
                                'then': 'C'
                              },
                              {
                                'case': {
                                  r'$gte': [r'$average', 60]
                                },
                                'then': 'D'
                              }
                            ],
                            'default': 'F'
                          }
                        }
                      }
                    }
                  ]),
                  multi: true)
            ],
            ordered: false,
            updateOptions: UpdateOptions(
                writeConcern: WriteConcern(w: wMajority, wtimeout: 5000)));
        var res = await updateOperation.process();

        expect(res, isNotNull);
        expect(res[keyOk], 1.0);
        expect(res[keyN], 3);
        expect(res[keyNModified], 3);
      });
    });
    group('Update - wrapper', () {
      test('Update with Aggregation Pipeline', () async {
        if (!running4_2orGreater) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var (ret, _, _, _) = await collection.insertMany([
          {
            '_id': 1,
            'member': 'abc123',
            'status': 'A',
            'points': 2,
            'misc1': 'note to self: confirm status',
            'misc2': 'Need to activate'
          },
          {
            '_id': 2,
            'member': 'xyz123',
            'status': 'A',
            'points': 60,
            'misc1': 'reminder: ping me at 100pts',
            'misc2': 'Some random comment'
          },
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var updateManyOperation = UpdateManyOperation(
            collection,
            UpdateManyStatement(
                QueryUnion(<String, Object>{}),
                UpdateUnion([
                  {
                    r'$set': {
                      'status': 'Modified',
                      'comments': [r'$misc1', r'$misc2']
                    }
                  },
                  {
                    r'$unset': ['misc1', 'misc2']
                  }
                ])),
            ordered: false,
            updateManyOptions: UpdateManyOptions(
                writeConcern: WriteConcern(w: wMajority, wtimeout: 5000)));
        var (res, _) = await updateManyOperation.executeDocument();

        expect(res, isNotNull);
        expect(res.ok, 1.0);
        expect(res.nMatched, 2);
        expect(res.nModified, 2);
      });

      test('Update with Aggregation Pipeline - 2', () async {
        if (!running4_2orGreater) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var (ret, _, _, _) = await collection.insertMany([
          {
            '_id': 1,
            'tests': [95, 92, 90]
          },
          {
            '_id': 2,
            'tests': [94, 88, 90]
          },
          {
            '_id': 3,
            'tests': [70, 75, 82]
          }
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var updateManyOperation = UpdateManyOperation(
            collection,
            UpdateManyStatement(
                QueryUnion(<String, Object>{}),
                UpdateUnion([
                  {
                    r'$set': {
                      'average': {r'$avg': r'$tests'}
                    }
                  },
                  {
                    r'$set': {
                      'grade': {
                        r'$switch': {
                          'branches': [
                            {
                              'case': {
                                r'$gte': [r'$average', 90]
                              },
                              'then': 'A'
                            },
                            {
                              'case': {
                                r'$gte': [r'$average', 80]
                              },
                              'then': 'B'
                            },
                            {
                              'case': {
                                r'$gte': [r'$average', 70]
                              },
                              'then': 'C'
                            },
                            {
                              'case': {
                                r'$gte': [r'$average', 60]
                              },
                              'then': 'D'
                            }
                          ],
                          'default': 'F'
                        }
                      }
                    }
                  }
                ])),
            ordered: false,
            updateManyOptions: UpdateManyOptions(
                writeConcern: WriteConcern(w: wMajority, wtimeout: 5000)));
        var (res, _) = await updateManyOperation.executeDocument();

        expect(res, isNotNull);
        expect(res.ok, 1.0);
        expect(res.nMatched, 3);
        expect(res.nModified, 3);
      });
    });

    group('Update - Modern Collection helper', () {
      test('Update with Aggregation Pipeline', () async {
        if (!running4_2orGreater) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var (ret, _, _, _) = await collection.insertMany([
          {
            '_id': 1,
            'member': 'abc123',
            'status': 'A',
            'points': 2,
            'misc1': 'note to self: confirm status',
            'misc2': 'Need to activate'
          },
          {
            '_id': 2,
            'member': 'xyz123',
            'status': 'A',
            'points': 60,
            'misc1': 'reminder: ping me at 100pts',
            'misc2': 'Some random comment'
          },
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var (res, _) = await collection.updateMany(
            null,
            (AggregationPipelineBuilder()
                  ..addStage(SetStage({
                    'status': 'Modified',
                    'comments': [r'$misc1', r'$misc2']
                  }))
                  ..addStage(Unset(['misc1', 'misc2'])))
                .build(),
            writeConcern: WriteConcern(w: wMajority, wtimeout: 5000));

        expect(res, isNotNull);
        expect(res.isSuccess, isTrue);
        expect(res.nMatched, 2);
        expect(res.nModified, 2);

        var elements = await collection.findOriginal(where).toList();

        expect(elements, isNotEmpty);
        expect(elements.first['status'], 'Modified');
        expect(elements.first['points'], 2);
        expect(elements.last['status'], 'Modified');
        expect(elements.last['points'], 60);
      });

      test('Update with Aggregation Pipeline - 2', () async {
        if (!running4_2orGreater) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var (ret, _, _, _) = await collection.insertMany([
          {
            '_id': 1,
            'tests': [95, 92, 90]
          },
          {
            '_id': 2,
            'tests': [94, 88, 90]
          },
          {
            '_id': 3,
            'tests': [70, 75, 82]
          }
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var (res, _) = await collection.updateMany(
            null,
            (AggregationPipelineBuilder()
                  ..addStage(SetStage({
                    'average': {r'$avg': r'$tests'}
                  }))
                  ..addStage(SetStage({
                    'grade': {
                      r'$switch': {
                        'branches': [
                          {
                            'case': {
                              r'$gte': [r'$average', 90]
                            },
                            'then': 'A'
                          },
                          {
                            'case': {
                              r'$gte': [r'$average', 80]
                            },
                            'then': 'B'
                          },
                          {
                            'case': {
                              r'$gte': [r'$average', 70]
                            },
                            'then': 'C'
                          },
                          {
                            'case': {
                              r'$gte': [r'$average', 60]
                            },
                            'then': 'D'
                          }
                        ],
                        'default': 'F'
                      }
                    }
                  })))
                .build(),
            writeConcern: WriteConcern(w: wMajority, wtimeout: 5000));

        expect(res, isNotNull);
        expect(res.isSuccess, isTrue);
        expect(res.nMatched, 3);
        expect(res.nModified, 3);

        var elements = await collection.findOriginal(where).toList();

        expect(elements, isNotEmpty);
        expect(elements.length, 3);
        expect(elements.first['average'], 92.33333333333333);
        expect(elements.first['grade'], 'A');
        expect(elements.last['average'], 75.66666666666667);
        expect(elements.last['grade'], 'C');
      });
    });
    group('Update - Collection helpers updateOne, updateMany and replaceOne',
        () {
      test('Update with Aggregation Pipeline', () async {
        if (!running4_2orGreater) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var (ret, _, _, _) = await collection.insertMany([
          {
            '_id': 1,
            'member': 'abc123',
            'status': 'A',
            'points': 2,
            'misc1': 'note to self: confirm status',
            'misc2': 'Need to activate'
          },
          {
            '_id': 2,
            'member': 'xyz123',
            'status': 'A',
            'points': 60,
            'misc1': 'reminder: ping me at 100pts',
            'misc2': 'Some random comment'
          },
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var (res, _) = await collection.updateMany(
            null,
            (AggregationPipelineBuilder()
                  ..addStage(SetStage({
                    'status': 'Modified',
                    'comments': [r'$misc1', r'$misc2']
                  }))
                  ..addStage(Unset(['misc1', 'misc2'])))
                .build(),
            writeConcern: WriteConcern(w: wMajority, wtimeout: 5000));

        expect(res, isNotNull);
        expect(res.ok, 1.0);
        expect(res.nMatched, 2);
        expect(res.nModified, 2);

        var elements = await collection.findOriginal(where).toList();

        expect(elements, isNotEmpty);
        expect(elements.first['status'], 'Modified');
        expect(elements.first['points'], 2);
        expect(elements.last['status'], 'Modified');
        expect(elements.last['points'], 60);
      });

      test('Update with Aggregation Pipeline - 2', () async {
        if (!running4_2orGreater) {
          return;
        }
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var (ret, _, _, _) = await collection.insertMany([
          {
            '_id': 1,
            'tests': [95, 92, 90]
          },
          {
            '_id': 2,
            'tests': [94, 88, 90]
          },
          {
            '_id': 3,
            'tests': [70, 75, 82]
          }
        ]);
        expect(ret.ok, 1.0);
        expect(ret.isSuccess, isTrue);

        var (res, _) = await collection.updateMany(
            null,
            (AggregationPipelineBuilder()
                  ..addStage(SetStage({
                    'average': {r'$avg': r'$tests'}
                  }))
                  ..addStage(SetStage({
                    'grade': {
                      r'$switch': {
                        'branches': [
                          {
                            'case': {
                              r'$gte': [r'$average', 90]
                            },
                            'then': 'A'
                          },
                          {
                            'case': {
                              r'$gte': [r'$average', 80]
                            },
                            'then': 'B'
                          },
                          {
                            'case': {
                              r'$gte': [r'$average', 70]
                            },
                            'then': 'C'
                          },
                          {
                            'case': {
                              r'$gte': [r'$average', 60]
                            },
                            'then': 'D'
                          }
                        ],
                        'default': 'F'
                      }
                    }
                  })))
                .build(),
            writeConcern: WriteConcern(w: wMajority, wtimeout: 5000));

        expect(res, isNotNull);
        expect(res.ok, 1.0);
        expect(res.nMatched, 3);
        expect(res.nModified, 3);

        var elements = await collection.findOriginal(where).toList();

        expect(elements, isNotEmpty);
        expect(elements.length, 3);
        expect(elements.first['average'], 92.33333333333333);
        expect(elements.first['grade'], 'A');
        expect(elements.last['average'], 75.66666666666667);
        expect(elements.last['grade'], 'C');
      });
    });
  });
  tearDownAll(() async {
    await client.connect();
    db = client.db();
    await Future.forEach(usedCollectionNames,
        (String collectionName) => db.collection(collectionName).drop());
    await client.close();
  });
}
