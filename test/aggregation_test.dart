import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'utils/insert_cake_sales_db.dart';

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
    await client.connect();
    db = client.db();
  }

  Future cleanupDatabase() async {
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
      group(r'$setWindowFields', () {
        test('output the cumulative cake sales quantity for each state',
            () async {
          if (!running4_2orGreater) {
            return;
          }
          var expectedResult = [
            {
              '_id': 4,
              'type': 'strawberry',
              'orderDate': DateTime.parse("2019-05-18T16:09:01Z"),
              'state': "CA",
              'price': 41,
              'quantity': 162,
              'cumulativeQuantityForState': 162
            },
            {
              '_id': 0,
              'type': "chocolate",
              'orderDate': DateTime.parse("2020-05-18T14:10:30Z"),
              'state': "CA",
              'price': 13,
              'quantity': 120,
              'cumulativeQuantityForState': 282
            },
            {
              '_id': 2,
              'type': "vanilla",
              'orderDate': DateTime.parse("2021-01-11T06:31:15Z"),
              'state': "CA",
              'price': 12,
              'quantity': 145,
              'cumulativeQuantityForState': 427
            },
            {
              "_id": 5,
              "type": "strawberry",
              "orderDate": DateTime.parse("2019-01-08T06:12:03Z"),
              "state": "WA",
              "price": 43,
              "quantity": 134,
              "cumulativeQuantityForState": 134
            },
            {
              "_id": 3,
              "type": "vanilla",
              "orderDate": DateTime.parse("2020-02-08T13:13:23Z"),
              "state": "WA",
              "price": 13,
              "quantity": 104,
              "cumulativeQuantityForState": 238
            },
            {
              "_id": 1,
              "type": "chocolate",
              "orderDate": DateTime.parse("2021-03-20T11:30:05Z"),
              "state": "WA",
              "price": 14,
              "quantity": 140,
              "cumulativeQuantityForState": 378
            }
          ];
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);

          var (ret, _, _, _) = await insertCakeSales(collection);
          expect(ret.ok, 1.0);
          expect(ret.isSuccess, isTrue);

          final pipeline = AggregationPipelineBuilder()
              .addStage(SetWindowFields(
                  partitionBy: r'$state',
                  sortBy: {'orderDate': 1},
                  output: Output(
                      'cumulativeQuantityForState', Sum(r'$quantity'),
                      documents: ['unbounded', 'current'])))
              .build();
          var res = await MongoCollection(db, collectionName)
              .modernAggregate(pipeline)
              .toList();
          expect(res, isNotNull);
          expect(res, expectedResult);
        });
        test(
            'put the cumulative cake sales quantity for each \$year in orderDate',
            () async {
          if (!running4_2orGreater) {
            return;
          }
          var expectedResult = [
            {
              "_id": 5,
              "type": "strawberry",
              "orderDate": DateTime.parse("2019-01-08T06:12:03Z"),
              "state": "WA",
              "price": 43,
              "quantity": 134,
              "cumulativeQuantityForYear": 134
            },
            {
              "_id": 4,
              "type": "strawberry",
              "orderDate": DateTime.parse("2019-05-18T16:09:01Z"),
              "state": "CA",
              "price": 41,
              "quantity": 162,
              "cumulativeQuantityForYear": 296
            },
            {
              "_id": 3,
              "type": "vanilla",
              "orderDate": DateTime.parse("2020-02-08T13:13:23Z"),
              "state": "WA",
              "price": 13,
              "quantity": 104,
              "cumulativeQuantityForYear": 104
            },
            {
              "_id": 0,
              "type": "chocolate",
              "orderDate": DateTime.parse("2020-05-18T14:10:30Z"),
              "state": "CA",
              "price": 13,
              "quantity": 120,
              "cumulativeQuantityForYear": 224
            },
            {
              "_id": 2,
              "type": "vanilla",
              "orderDate": DateTime.parse("2021-01-11T06:31:15Z"),
              "state": "CA",
              "price": 12,
              "quantity": 145,
              "cumulativeQuantityForYear": 145
            },
            {
              "_id": 1,
              "type": "chocolate",
              "orderDate": DateTime.parse("2021-03-20T11:30:05Z"),
              "state": "WA",
              "price": 14,
              "quantity": 140,
              "cumulativeQuantityForYear": 285
            }
          ];
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);

          var (ret, _, _, _) = await insertCakeSales(collection);
          expect(ret.ok, 1.0);
          expect(ret.isSuccess, isTrue);

          final pipeline = AggregationPipelineBuilder()
              .addStage(SetWindowFields(partitionBy: {
                r'$year': r"$orderDate"
              }, sortBy: {
                'orderDate': 1
              }, output: {
                'cumulativeQuantityForYear': {
                  r'$sum': r"$quantity",
                  'window': {
                    'documents': ["unbounded", "current"]
                  }
                }
              }))
              .build();
          var res = await MongoCollection(db, collectionName)
              .modernAggregate(pipeline)
              .toList();
          expect(res, isNotNull);
          expect(res, expectedResult);
        });
        test('output the moving average for the cake sales quantity', () async {
          if (!running4_2orGreater) {
            return;
          }
          var expectedResult = [
            {
              "_id": 5,
              "type": "strawberry",
              "orderDate": DateTime.parse("2019-01-08T06:12:03Z"),
              "state": "WA",
              "price": 43,
              "quantity": 134,
              "averageQuantity": 134
            },
            {
              "_id": 4,
              "type": "strawberry",
              "orderDate": DateTime.parse("2019-05-18T16:09:01Z"),
              "state": "CA",
              "price": 41,
              "quantity": 162,
              "averageQuantity": 148
            },
            {
              "_id": 3,
              "type": "vanilla",
              "orderDate": DateTime.parse("2020-02-08T13:13:23Z"),
              "state": "WA",
              "price": 13,
              "quantity": 104,
              "averageQuantity": 104
            },
            {
              "_id": 0,
              "type": "chocolate",
              "orderDate": DateTime.parse("2020-05-18T14:10:30Z"),
              "state": "CA",
              "price": 13,
              "quantity": 120,
              "averageQuantity": 112
            },
            {
              "_id": 2,
              "type": "vanilla",
              "orderDate": DateTime.parse("2021-01-11T06:31:15Z"),
              "state": "CA",
              "price": 12,
              "quantity": 145,
              "averageQuantity": 145
            },
            {
              "_id": 1,
              "type": "chocolate",
              "orderDate": DateTime.parse("2021-03-20T11:30:05Z"),
              "state": "WA",
              "price": 14,
              "quantity": 140,
              "averageQuantity": 142.5
            }
          ];
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);

          var (ret, _, _, _) = await insertCakeSales(collection);
          expect(ret.ok, 1.0);
          expect(ret.isSuccess, isTrue);

          final pipeline = AggregationPipelineBuilder()
              .addStage(SetWindowFields(partitionBy: {
                r'$year': r"$orderDate"
              }, sortBy: {
                'orderDate': 1
              }, output: [
                Output('averageQuantity', Avg(r'$quantity'), documents: [-1, 0])
              ]))
              .build();
          var res = await MongoCollection(db, collectionName)
              .modernAggregate(pipeline)
              .toList();
          expect(res, isNotNull);
          expect(res, expectedResult);
        });
        test(
            'output the cumulative and maximum cake sales quantity '
            r'values for each $year in orderDate', () async {
          if (!running4_2orGreater) {
            return;
          }
          var expectedResult = [
            {
              "_id": 5,
              "type": "strawberry",
              "orderDate": DateTime.parse("2019-01-08T06:12:03Z"),
              "state": "WA",
              "price": 43,
              "quantity": 134,
              "cumulativeQuantityForYear": 134,
              "maximumQuantityForYear": 162
            },
            {
              "_id": 4,
              "type": "strawberry",
              "orderDate": DateTime.parse("2019-05-18T16:09:01Z"),
              "state": "CA",
              "price": 41,
              "quantity": 162,
              "cumulativeQuantityForYear": 296,
              "maximumQuantityForYear": 162
            },
            {
              "_id": 3,
              "type": "vanilla",
              "orderDate": DateTime.parse("2020-02-08T13:13:23Z"),
              "state": "WA",
              "price": 13,
              "quantity": 104,
              "cumulativeQuantityForYear": 104,
              "maximumQuantityForYear": 120
            },
            {
              "_id": 0,
              "type": "chocolate",
              "orderDate": DateTime.parse("2020-05-18T14:10:30Z"),
              "state": "CA",
              "price": 13,
              "quantity": 120,
              "cumulativeQuantityForYear": 224,
              "maximumQuantityForYear": 120
            },
            {
              "_id": 2,
              "type": "vanilla",
              "orderDate": DateTime.parse("2021-01-11T06:31:15Z"),
              "state": "CA",
              "price": 12,
              "quantity": 145,
              "cumulativeQuantityForYear": 145,
              "maximumQuantityForYear": 145
            },
            {
              "_id": 1,
              "type": "chocolate",
              "orderDate": DateTime.parse("2021-03-20T11:30:05Z"),
              "state": "WA",
              "price": 14,
              "quantity": 140,
              "cumulativeQuantityForYear": 285,
              "maximumQuantityForYear": 145
            }
          ];
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);

          var (ret, _, _, _) = await insertCakeSales(collection);
          expect(ret.ok, 1.0);
          expect(ret.isSuccess, isTrue);

          final pipeline = AggregationPipelineBuilder()
              .addStage(SetWindowFields(partitionBy: {
                r'$year': r"$orderDate"
              }, sortBy: {
                'orderDate': 1
              }, output: [
                Output('cumulativeQuantityForYear', Sum(r'$quantity'),
                    documents: ["unbounded", "current"]),
                Output('maximumQuantityForYear', Max(r'$quantity'),
                    documents: ["unbounded", "unbounded"])
              ]))
              .build();
          // Missing ...
          //  maximumQuantityForYear: {
          // $max: "$quantity",
          // window: {
          //    documents: [ "unbounded", "unbounded" ]
          // }
          // }
          var res = await MongoCollection(db, collectionName)
              .modernAggregate(pipeline)
              .toList();
          expect(res, isNotNull);
          expect(res, expectedResult);
        });
        test(
            r"return the sum of the quantity values of cakes sold for orders "
            "within plus or minus 10 dollars of the current document's price value",
            () async {
          if (!running4_2orGreater) {
            return;
          }
          var expectedResult = [
            {
              "_id": 2,
              "type": "vanilla",
              "orderDate": DateTime.parse("2021-01-11T06:31:15Z"),
              "state": "CA",
              "price": 12,
              "quantity": 145,
              "quantityFromSimilarOrders": 265
            },
            {
              "_id": 0,
              "type": "chocolate",
              "orderDate": DateTime.parse("2020-05-18T14:10:30Z"),
              "state": "CA",
              "price": 13,
              "quantity": 120,
              "quantityFromSimilarOrders": 265
            },
            {
              "_id": 4,
              "type": "strawberry",
              "orderDate": DateTime.parse("2019-05-18T16:09:01Z"),
              "state": "CA",
              "price": 41,
              "quantity": 162,
              "quantityFromSimilarOrders": 162
            },
            {
              "_id": 3,
              "type": "vanilla",
              "orderDate": DateTime.parse("2020-02-08T13:13:23Z"),
              "state": "WA",
              "price": 13,
              "quantity": 104,
              "quantityFromSimilarOrders": 244
            },
            {
              "_id": 1,
              "type": "chocolate",
              "orderDate": DateTime.parse("2021-03-20T11:30:05Z"),
              "state": "WA",
              "price": 14,
              "quantity": 140,
              "quantityFromSimilarOrders": 244
            },
            {
              "_id": 5,
              "type": "strawberry",
              "orderDate": DateTime.parse("2019-01-08T06:12:03Z"),
              "state": "WA",
              "price": 43,
              "quantity": 134,
              "quantityFromSimilarOrders": 134
            }
          ];
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);

          var (ret, _, _, _) = await insertCakeSales(collection);
          expect(ret.ok, 1.0);
          expect(ret.isSuccess, isTrue);

          final pipeline = AggregationPipelineBuilder()
              .addStage(SetWindowFields(
                  partitionBy: r'$state',
                  sortBy: {'price': 1},
                  output: Output('quantityFromSimilarOrders', Sum(r'$quantity'),
                      range: [-10, 10])))
              .build();
          var res = await MongoCollection(db, collectionName)
              .modernAggregate(pipeline)
              .toList();
          expect(res, isNotNull);
          expect(res, expectedResult);
        });
        test(
            r" outputs an array of orderDate values for each state that match "
            "the specified time range", () async {
          if (!running4_2orGreater) {
            return;
          }
          var expectedResult = [
            {
              "_id": 4,
              "type": "strawberry",
              "orderDate": DateTime.parse("2019-05-18T16:09:01Z"),
              "state": "CA",
              "price": 41,
              "quantity": 162,
              "recentOrders": [DateTime.parse("2019-05-18T16:09:01Z")]
            },
            {
              "_id": 0,
              "type": "chocolate",
              "orderDate": DateTime.parse("2020-05-18T14:10:30Z"),
              "state": "CA",
              "price": 13,
              "quantity": 120,
              "recentOrders": [
                DateTime.parse("2019-05-18T16:09:01Z"),
                DateTime.parse("2020-05-18T14:10:30Z"),
                DateTime.parse("2021-01-11T06:31:15Z")
              ]
            },
            {
              "_id": 2,
              "type": "vanilla",
              "orderDate": DateTime.parse("2021-01-11T06:31:15Z"),
              "state": "CA",
              "price": 12,
              "quantity": 145,
              "recentOrders": [
                DateTime.parse("2019-05-18T16:09:01Z"),
                DateTime.parse("2020-05-18T14:10:30Z"),
                DateTime.parse("2021-01-11T06:31:15Z")
              ]
            },
            {
              "_id": 5,
              "type": "strawberry",
              "orderDate": DateTime.parse("2019-01-08T06:12:03Z"),
              "state": "WA",
              "price": 43,
              "quantity": 134,
              "recentOrders": [DateTime.parse("2019-01-08T06:12:03Z")]
            },
            {
              "_id": 3,
              "type": "vanilla",
              "orderDate": DateTime.parse("2020-02-08T13:13:23Z"),
              "state": "WA",
              "price": 13,
              "quantity": 104,
              "recentOrders": [
                DateTime.parse("2019-01-08T06:12:03Z"),
                DateTime.parse("2020-02-08T13:13:23Z")
              ]
            },
            {
              "_id": 1,
              "type": "chocolate",
              "orderDate": DateTime.parse("2021-03-20T11:30:05Z"),
              "state": "WA",
              "price": 14,
              "quantity": 140,
              "recentOrders": [
                DateTime.parse("2019-01-08T06:12:03Z"),
                DateTime.parse("2020-02-08T13:13:23Z"),
                DateTime.parse("2021-03-20T11:30:05Z")
              ]
            }
          ];
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);

          var (ret, _, _, _) = await insertCakeSales(collection);
          expect(ret.ok, 1.0);
          expect(ret.isSuccess, isTrue);

          final pipeline = AggregationPipelineBuilder()
              .addStage(SetWindowFields(
                  partitionBy: r'$state',
                  sortBy: {'orderDate': 1},
                  output: Output('recentOrders', Push(r'$orderDate'),
                      range: ["unbounded", 10], unit: "month")))
              .build();
          var res = await MongoCollection(db, collectionName)
              .modernAggregate(pipeline)
              .toList();
          expect(res, isNotNull);
          expect(res, expectedResult);
        });
        test(
            r" outputs an array of orderDate values for each state that match "
            "the specified time range - Negative Upper bound", () async {
          if (!running4_2orGreater) {
            return;
          }
          var expectedResult = [
            {
              "_id": 4,
              "type": "strawberry",
              "orderDate": DateTime.parse("2019-05-18T16:09:01Z"),
              "state": "CA",
              "price": 41,
              "quantity": 162,
              "recentOrders": []
            },
            {
              "_id": 0,
              "type": "chocolate",
              "orderDate": DateTime.parse("2020-05-18T14:10:30Z"),
              "state": "CA",
              "price": 13,
              "quantity": 120,
              "recentOrders": [DateTime.parse("2019-05-18T16:09:01Z")]
            },
            {
              "_id": 2,
              "type": "vanilla",
              "orderDate": DateTime.parse("2021-01-11T06:31:15Z"),
              "state": "CA",
              "price": 12,
              "quantity": 145,
              "recentOrders": [DateTime.parse("2019-05-18T16:09:01Z")]
            },
            {
              "_id": 5,
              "type": "strawberry",
              "orderDate": DateTime.parse("2019-01-08T06:12:03Z"),
              "state": "WA",
              "price": 43,
              "quantity": 134,
              "recentOrders": []
            },
            {
              "_id": 3,
              "type": "vanilla",
              "orderDate": DateTime.parse("2020-02-08T13:13:23Z"),
              "state": "WA",
              "price": 13,
              "quantity": 104,
              "recentOrders": [DateTime.parse("2019-01-08T06:12:03Z")]
            },
            {
              "_id": 1,
              "type": "chocolate",
              "orderDate": DateTime.parse("2021-03-20T11:30:05Z"),
              "state": "WA",
              "price": 14,
              "quantity": 140,
              "recentOrders": [
                DateTime.parse("2019-01-08T06:12:03Z"),
                DateTime.parse("2020-02-08T13:13:23Z")
              ]
            }
          ];
          var collectionName = getRandomCollectionName();
          var collection = db.collection(collectionName);

          var (ret, _, _, _) = await insertCakeSales(collection);
          expect(ret.ok, 1.0);
          expect(ret.isSuccess, isTrue);

          final pipeline = AggregationPipelineBuilder()
              .addStage(SetWindowFields(
                  partitionBy: r'$state',
                  sortBy: {'orderDate': 1},
                  output: Output('recentOrders', Push(r'$orderDate'),
                      range: ["unbounded", -10], unit: "month")))
              .build();
          var res = await MongoCollection(db, collectionName)
              .modernAggregate(pipeline)
              .toList();
          expect(res, isNotNull);
          expect(res, expectedResult);
        });
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
