@Timeout(Duration(seconds: 30))

import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/cursor/modern_cursor.dart';
import 'package:mongo_dart/src/database/commands/administration_commands/wrapper/create_collection/create_collection_options.dart';
import 'package:mongo_dart/src/database/commands/aggreagation_commands/aggregate/aggregate_operation.dart';
import 'package:mongo_dart/src/database/commands/aggreagation_commands/count/count_operation.dart';
import 'package:mongo_dart/src/database/commands/aggreagation_commands/count/count_options.dart';
import 'package:mongo_dart/src/database/commands/aggreagation_commands/distinct/distinct_operation.dart';
import 'package:mongo_dart/src/database/commands/aggreagation_commands/distinct/distinct_options.dart';
import 'package:mongo_dart/src/database/commands/aggreagation_commands/wrapper/change_stream/change_stream_operation.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/find_operation/find_operation.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/find_operation/find_options.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/get_more_command/get_more_command.dart';
import 'package:mongo_dart/src/database/commands/parameters/read_concern.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';
import 'package:rational/rational.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'utils/insert_data.dart';

const dbName = 'test-mongo-dart';
const dbAddress = '127.0.0.1';

const DefaultUri = 'mongodb://$dbAddress:27017/$dbName';

var testDoc = {
  '_id': ObjectId.parse('6025b13eab1951094272d007'),
  'id': '03a091e2-fa67-4132-9237-f5b9ed3dbb39',
  'dataCadastro': '2021-02-11 19:35:41.998',
  'link': null,
  'icon': 'icon-pizza-1',
  'ativo': true,
  'order': 0,
  'midia': {
    'id': 'd54435d2-2fe3-4ea1-aa04-0ccdfade4c9f',
    'title': 'experimente-praias-1',
    'description': 'experimente-praias-1.jpg',
    'dataCadastro': '2021-02-10 14:23:23.224',
    'fisicalFilename': 'acd13d50-15af-45fd-98f9-0903d1bb3ea5.jpg',
    'originalFilename': 'experimente-praias-1.jpg',
    'link':
        'http://localhost:4002/storage/turismo/midias/acd13d50-15af-45fd-98f9-0903d1bb3ea5.jpg',
    'mimeType': 'image/jpeg',
    'tipo': null
  },
  'infos': [
    {
      'id': '7df40302-1112-4ee2-bb66-0950951e2264',
      'title': 'ONDE COMER EM RIO DAS OSTRAS',
      'lang': 'pt',
      'content':
          'Bares, restaurantes e quiosques oferecem o melhor da gastronomia regional, onde os festivais como os de Frutos do Mar, Pizza, Pão e Petiscos de Quiosque, são sempre destaque.'
    },
    {
      'id': '91fb8685-724d-49ba-b65b-1fb5c0cf40df',
      'title': 'BAR DA BOCA',
      'lang': 'en',
      'content':
          'Bars, restaurants and kiosks suitable for the best of regional cuisine, where festivals such as Seafood, Pizza, Bread and Kiosk Snacks are always the highlight.'
    }
  ],
  'pontosGastronomicos': [
    {
      'id': '208a3f93-9fcb-4db7-ac44-bb11b86a2d31',
      'infos': [
        {
          'id': '925ed160-9276-4046-87a2-d1f37547f7cb',
          'title': 'BAR DA BOCA',
          'lang': 'pt',
          'content': 'Ótima experiência com  o  melhor chope de Rio das Ostras'
        },
        {
          'id': 'abc2ef60-4807-4b16-8d3e-95223abe0524',
          'title': 'BAR DA BOCA',
          'lang': 'en',
          'content':
              'Great experience with the best draft beer in Rio das Ostras'
        }
      ],
      'midias': [
        {
          'id': 'd54435d2-2fe3-4ea1-aa04-0ccdfade4c9f',
          'title': 'experimente-praias-1',
          'description': 'experimente-praias-1.jpg',
          'dataCadastro': '2021-02-10 14:23:23.224',
          'fisicalFilename': 'acd13d50-15af-45fd-98f9-0903d1bb3ea5.jpg',
          'originalFilename': 'experimente-praias-1.jpg',
          'link':
              'http://localhost:4002/storage/turismo/midias/acd13d50-15af-45fd-98f9-0903d1bb3ea5.jpg',
          'mimeType': 'image/jpeg',
          'tipo': null
        }
      ],
      'ativo': true,
      'dataCadastro': '2021-02-11 19:51:26.702',
      'order': 0,
      'link': null,
      'email': 'bardaboca@yahoo.com.br',
      'logradouro': 'Rua Teresópolis',
      'bairro': 'Boca da Barra',
      'numero': '69',
      'telefone1': '1111111111 ',
      'telefone2': '2222222222',
      'horarioFuncionamento': '10h as 20h',
      'latitude': null,
      'longitude': null,
      'categoria': null,
      'logo': null,
      'whatsapp': null,
      'tipoDeCozinha': null,
      'capacidade': null,
      'site': null,
      'facebook': null,
      'youtube': null,
      'instagram': null,
      'observacao': null,
      'estruturas': [
        {
          'id': '8df75907-4a61-49c1-9ce9-fa1b22b903dc',
          'icon': 'turismopmro-arcondicionado',
          'infos': [
            {
              'id': '632a34a2-30b5-4589-b696-ab023dcd742f',
              'title': 'Ar Condicionado',
              'lang': 'pt'
            },
            {
              'id': '274a0116-218f-4148-bd54-fa1840c5a0d0',
              'title': 'Air Conditioner',
              'lang': 'en'
            }
          ]
        },
        {
          'id': '6ef1036c-87fd-4a0b-a6e3-026fb8599431',
          'icon': 'turismopmro-wifi',
          'infos': [
            {
              'id': '2a83927e-7da9-4a8b-bd02-e8fc2006430e',
              'title': 'Wifi',
              'lang': 'pt'
            },
            {
              'id': 'ebf3cd36-c0bf-4549-967c-0e55817c585c',
              'title': 'Wifi',
              'lang': 'en'
            }
          ]
        },
        {
          'id': 'ce40ef4a-f96a-4376-9319-0858429a8692',
          'icon': 'turismopmro-cigarro',
          'infos': [
            {
              'id': '5b11a221-f728-4414-9ad4-e999b855a92d',
              'title': 'Área de fumantes',
              'lang': 'pt'
            },
            {
              'id': 'a0d8ad50-49fb-4d9c-b7ca-75b198b13e30',
              'title': 'Smoking area',
              'lang': 'en'
            }
          ]
        }
      ]
    }
  ]
};

final Matcher throwsMongoDartError = throwsA(TypeMatcher<MongoDartError>());

Db db;
Uuid uuid = Uuid();
List<String> usedCollectionNames = [];

String getRandomCollectionName() {
  var name = uuid.v4();
  usedCollectionNames.add(name);
  return name;
}

void main() async {
  Future initializeDatabase() async {
    db = Db(DefaultUri);
    await db.open();
  }

  Future cleanupDatabase() async {
    await db.close();
  }

  group('Read Operations', () {
    var cannotRunTests = false;
    setUp(() async {
      await initializeDatabase();
      if (db.masterConnection == null ||
          !db.masterConnection.serverCapabilities.supportsOpMsg) {
        cannotRunTests = true;
      }
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    test('Simple read', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);

      var ret = await insertManyDocuments(collection, 10000);
      expect(ret.isSuccess, isTrue);

      var result = await collection.modernFind().toList();
      expect(result.length, 10000);
    }, skip: cannotRunTests);

    test('Simple read - extract sub-document', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);

      var ret = await collection.insertOne(testDoc);
      expect(ret.isSuccess, isTrue);

      var result = await collection.modernFind(filter: {
        'pontosGastronomicos.id': '208a3f93-9fcb-4db7-ac44-bb11b86a2d31'
      }, projection: {
        '_id': 0,
        'pontosGastronomicos': {
          r'$elemMatch': {'id': '208a3f93-9fcb-4db7-ac44-bb11b86a2d31'}
        }
      }).toList();
      expect(result.length, 1);
      expect(result.first['pontosGastronomicos'].first['id'],
          '208a3f93-9fcb-4db7-ac44-bb11b86a2d31');

      var resultOne = await collection.modernFindOne(
          selector: where
            ..eq('pontosGastronomicos.id',
                '208a3f93-9fcb-4db7-ac44-bb11b86a2d31')
            ..paramFields = {
              '_id': 0,
              'pontosGastronomicos': {
                r'$elemMatch': {'id': '208a3f93-9fcb-4db7-ac44-bb11b86a2d31'}
              }
            });
      expect(resultOne['pontosGastronomicos'].first['id'],
          '208a3f93-9fcb-4db7-ac44-bb11b86a2d31');
      expect(result.first['pontosGastronomicos'].first['id'],
          resultOne['pontosGastronomicos'].first['id']);

      resultOne = await collection.modernFindOne(filter: {
        'pontosGastronomicos': {
          r'$elemMatch': {'id': '208a3f93-9fcb-4db7-ac44-bb11b86a2d31'}
        }
      }, projection: {
        '_id': 0,
        'pontosGastronomicos': {
          r'$elemMatch': {'id': '208a3f93-9fcb-4db7-ac44-bb11b86a2d31'}
        }
      });
      expect(resultOne['pontosGastronomicos'].first['id'],
          '208a3f93-9fcb-4db7-ac44-bb11b86a2d31');

      var cursor = collection.modernAggregateCursor([
        {
          r'$replaceRoot': {
            'newRoot': {
              r'$arrayElemAt': [
                {
                  r'$filter': {
                    'input': r'$pontosGastronomicos',
                    'as': 'pontosGastronomicos',
                    'cond': {
                      /* resolve to a boolean value and determine if an element should be included in the output array. */
                      r'$eq': [
                        r'$$pontosGastronomicos.id',
                        '208a3f93-9fcb-4db7-ac44-bb11b86a2d31'
                      ]
                    }
                  }
                },
                0 /* the element at the specified array index */
              ]
            }
          }
        }
      ]);
      var doc = await cursor.onlyFirst();
      expect(doc['id'], '208a3f93-9fcb-4db7-ac44-bb11b86a2d31');

    }, skip: cannotRunTests);

    test(r'Select with $where', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);

      var ret = await insertManyDocuments(collection, 10000);
      expect(ret.isSuccess, isTrue);

      var result = await collection.modernFind(filter: {
        r'$where': 'function() { '
            ' return (this.a < 100) }'
      }).toList();
      expect(result.length, 100);
    }, skip: cannotRunTests);

    test(r'Select with $where - possible injection', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);

      var ret = await insertManyDocuments(collection, 10000);
      expect(ret.isSuccess, isTrue);

      // instead of 100
      var fromUser = '1 || "" == "" ';

      var result = await collection.modernFind(filter: {
        r'$where': 'function() { return (this.a < $fromUser) }'
      }).toList();

      expect(result.length, 10000);
    }, skip: cannotRunTests);

    test('Simple read - using stream', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);

      var ret = await insertManyDocuments(collection, 10000);
      expect(ret.isSuccess, isTrue);

      var result = [];
      var stream = collection.modernFind();
      await for (var element in stream) {
        result.add(element);
      }
      expect(result.length, 10000);
    }, skip: cannotRunTests);
    test('Simple read - using stream from cursor', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);

      var ret = await insertManyDocuments(collection, 10000);
      expect(ret.isSuccess, isTrue);

      var result = [];
      var cursor = ModernCursor(FindOperation(collection));
      await for (var element in cursor.stream) {
        result.add(element);
      }
      expect(result.length, 10000);
    }, skip: cannotRunTests);

    test('Simple read error- using wrong stream from cursor', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);

      var ret = await insertManyDocuments(collection, 10000);
      expect(ret.isSuccess, isTrue);

      var result = [];
      var cursor = ModernCursor(FindOperation(collection));
      try {
        await for (var element in cursor.changeStream) {
          result.add(element);
        }
        // should not pass by here but catch the error
        expect('No Error', 'MongoDartError');
      } on MongoDartError {
        // OK!!
      } catch (e) {
        expect('$e', 'MongoDartError');
      }
    }, skip: cannotRunTests);

    test('Simple read from capped collection', () async {
      var collectionName = getRandomCollectionName();
      var resultMap = await db.createCollection(collectionName,
          createCollectionOptions:
              CreateCollectionOptions(capped: true, size: 5242880, max: 5000));
      expect(resultMap[keyOk], 1.0);
      var collection = db.collection(collectionName);

      await insertManyDocuments(collection, 10000);
      var result = await collection.modernFind().toList();

      expect(result.length, 5000);
    }, skip: cannotRunTests);

    group('Normal Cursor', () {
      test('Simple read from capped collection', () async {
        var collectionName = getRandomCollectionName();
        var resultMap = await db.createCollection(collectionName,
            createCollectionOptions: CreateCollectionOptions(
                capped: true, size: 5242880, max: 5000));
        expect(resultMap[keyOk], 1.0);
        var collection = db.collection(collectionName);

        await insertManyDocuments(collection, 120);

        var cursor = ModernCursor(FindOperation(collection));

        expect(cursor.state, State.INIT);

        await cursor.nextObject();

        // calling getMoreCommand after having a Cursor object
        // should not be done in production, as the Cursor instance
        // state will not be updated.
        // more, notice that with cursor nextObject we got one document,
        // but, internally, the cursor have already fetched from the server
        // a default 101 documents, so, when we run the getMore command
        // only 19 can be retrieved.
        var command = GetMoreCommand(collection, cursor.cursorId);
        var resultCommand = await command.execute();
        expect(resultCommand, isNotNull);
        expect(resultCommand[keyCursor], isNotNull);

        Map cursorMap = resultCommand[keyCursor];
        expect(cursorMap[keyFirstBatch], isNull);
        expect(cursorMap[keyNextBatch], isNotEmpty);
        expect(cursorMap[keyNextBatch].length, 19);
        expect(cursorMap[keyId], isZero);
        // Server automatically closed on end of selection
        /*  expect(cursor.state, State.CLOSED);
        expect(cursor.cursorId.value, isZero); */
      }, skip: cannotRunTests);
    });

    group('Tailable Cursor', () {
      test('Simple read from capped collection', () async {
        var collectionName = getRandomCollectionName();
        var resultMap = await db.createCollection(collectionName,
            createCollectionOptions: CreateCollectionOptions(
                capped: true, size: 5242880, max: 5000));
        expect(resultMap[keyOk], 1.0);
        var collection = db.collection(collectionName);

        await insertManyDocuments(collection, 110);
        var doc = await FindOperation(collection,
                findOptions: FindOptions(tailable: true))
            .execute();

        var cursor = ModernCursor.fromOpenId(
            collection, BsonLong((doc[keyCursor] as Map)[keyId] as int),
            tailable: true);

        expect(cursor.state, State.OPEN);

        var cursorResult = await cursor.nextObject();
        expect(cursor.state, State.OPEN);
        expect(cursor.cursorId.value, isPositive);
        expect(cursorResult['a'], 101);
        expect(cursorResult, isNotNull);

        var aResult = (cursorResult['a'] as int) + 1;
        var got110 = false;
        cursor.stream.listen((event) {
          expect(event['a'], aResult++);
          if (event['a'] == 110) {
            got110 = true;
          }
        });

        expect(cursor.state, State.OPEN);

        await Future.delayed(Duration(seconds: 3));

        await collection.insertOne({'a': 110});

        await Future.doWhile(() async {
          if (got110) {
            await cursor.close();
            return false;
          }
          await Future.delayed(Duration(seconds: 2));

          return true;
        });
        expect(cursor.state, State.CLOSED);
      });
      test('Simple read from capped collection with awaitData', () async {
        var collectionName = getRandomCollectionName();
        var resultMap = await db.createCollection(collectionName,
            createCollectionOptions: CreateCollectionOptions(
                capped: true, size: 5242880, max: 5000));
        expect(resultMap[keyOk], 1.0);
        var collection = db.collection(collectionName);

        await insertManyDocuments(collection, 110);
        var doc = await FindOperation(collection,
                findOptions: FindOptions(tailable: true, awaitData: true))
            .execute();

        var cursor = ModernCursor.fromOpenId(
            collection, BsonLong((doc[keyCursor] as Map)[keyId] as int),
            tailable: true);

        expect(cursor.state, State.OPEN);

        var cursorResult = await cursor.nextObject();
        expect(cursor.state, State.OPEN);
        expect(cursor.cursorId.value, isPositive);
        expect(cursorResult['a'], 101);
        expect(cursorResult, isNotNull);

        var aResult = (cursorResult['a'] as int) + 1;
        var got110 = false;
        var got111 = false;

        cursor.stream.listen((event) {
          expect(event['a'], aResult++);
          if (event['a'] == 110) {
            got110 = true;
          } else if (event['a'] == 111) {
            got111 = true;
          }
        });

        expect(cursor.state, State.OPEN);

        await Future.delayed(Duration(seconds: 2));

        await collection.insertOne({'a': 110});

        await Future.doWhile(() async {
          if (got111) {
            await cursor.close();
            return false;
          } else if (got110) {
            await collection.insertOne({'a': 111});
          }
          await Future.delayed(Duration(seconds: 1));

          return true;
        });
        expect(cursor.state, State.CLOSED);
      });

      // Reading with a tailable cursor on a capped collection
      // automatically closes the cursor if the result of the selection is empty
      test('Read from empty collection', () async {
        var collectionName = getRandomCollectionName();
        var resultMap = await db.createCollection(collectionName,
            createCollectionOptions: CreateCollectionOptions(
                capped: true, size: 5242880, max: 5000));
        expect(resultMap[keyOk], 1.0);
        var collection = db.collection(collectionName);

        var cursor = ModernCursor(FindOperation(collection,
            findOptions: FindOptions(tailable: true)));
        expect(cursor.state, State.INIT);

        expect(() => cursor.nextObject(), throwsMongoDartError);
      });

      test('Read from empty selection', () async {
        var collectionName = getRandomCollectionName();
        var resultMap = await db.createCollection(collectionName,
            createCollectionOptions: CreateCollectionOptions(
                capped: true, size: 5242880, max: 5000));
        expect(resultMap[keyOk], 1.0);
        var collection = db.collection(collectionName);

        await collection.insertMany([
          {'test': 1, 'state': 'A'},
          {'test': 2, 'state': 'B'},
          {'test': 3, 'state': 'A'},
          {'test': 4, 'state': 'A'}
        ]);
        var cursor = ModernCursor(FindOperation(collection,
            filter: <String, Object>{'state': 'C'},
            findOptions: FindOptions(tailable: true)));
        expect(cursor.state, State.INIT);

        var cursorResult = await cursor.nextObject();
        expect(cursorResult, isNull);
        expect(cursor.state, State.OPEN);
        expect(cursor.cursorId.value, isNonZero);

        await cursor.close();
      });
    }, skip: cannotRunTests);
  });

  group('Aggregate', () {
    var cannotRunTests = false;
    setUp(() async {
      await initializeDatabase();
      if (db.masterConnection == null ||
          !db.masterConnection.serverCapabilities.supportsOpMsg) {
        cannotRunTests = true;
      }
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    test('Simple Aggregate', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);

      await collection.insertMany(<Map<String, dynamic>>[
        {'game': 'At the Gates of Loyang', 'cost': Rational.parse('15.20')},
        {'game': 'Age of Steam', 'cost': Rational.parse('16.80')},
        {'game': 'Fresco', 'cost': Rational.parse('13')}
      ]);

      var pipeline = AggregationPipelineBuilder().addStage(Group(
          id: 'games',
          fields: {'total': Sum(Field('cost')), 'avg': Avg(Field('cost'))}));

      var result = await collection.modernAggregate(pipeline).toList();
      expect(result.first[key_id], 'games');
      expect(result.first['avg'], Rational.fromInt(15));
      expect(result.first['total'], Rational.fromInt(45));
    }, skip: cannotRunTests);

    group('admin/diagnostic pipeline', () {
      test('currentOp', () async {
        var stream = db.aggregate([
          {
            r'$currentOp': {'allUsers': true, 'idleConnections': true}
          },
          {
            r'$match': {
              'active': true,
              if (db.masterConnection.serverCapabilities.isShardedCluster)
                'op': 'getmore'
              else
                'command.aggregate': 1
            }
          }
        ]);

        var resultList = await stream.toList();
        if (db.masterConnection.serverCapabilities.fcv.compareTo('4.2') == -1) {
          if (db.masterConnection.serverCapabilities.isShardedCluster) {
            // one command per shard
            expect(resultList, isNotEmpty);
            expect(resultList.first['op'], 'getmore');
          } else {
            expect(resultList.length, 1);
            expect(resultList.first['op'], 'command');
          }
        } else {
          if (db.masterConnection.serverCapabilities.isShardedCluster) {
            // one command per shard
            expect(resultList, isNotEmpty);
            expect(resultList.first['type'], 'op');
            expect(resultList.first['op'], 'getmore');
          } else {
            expect(resultList.length, 1);
            expect(resultList.first['type'], 'op');
            expect(resultList.first['op'], 'command');
          }
        }
      });

      test('listLocalSessions', () async {
        var result = db.aggregate([
          {
            r'$listLocalSessions': {'allUsers': true}
          },
          {
            r'$match': {'active': true, 'command.aggregate': 1}
          }
        ]);

        var resultList = await result.toList();
        expect(resultList.length, 0);
      });
    });

    group('Normal Cursor', () {
      test('Aggregate', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var toInsert = <Map<String, dynamic>>[];

        // Avg 1 with 1 rating
        toInsert.add({
          'game': 'At the Gates of Loyang',
          'player': 'Dallas',
          'rating': 1,
          'v': 1
        });

        // Avg 3 with 1 rating
        toInsert.add(
            {'game': 'Age of Steam', 'player': 'Paul', 'rating': 3, 'v': 1});

        // Avg 2 with 2 ratings
        toInsert.add({'game': 'Fresco', 'player': 'Erin', 'rating': 3, 'v': 1});
        toInsert
            .add({'game': 'Fresco', 'player': 'Dallas', 'rating': 1, 'v': 1});

        // Avg 3.5 with 4 ratings
        toInsert.add(
            {'game': 'Ticket To Ride', 'player': 'Paul', 'rating': 4, 'v': 1});
        toInsert.add(
            {'game': 'Ticket To Ride', 'player': 'Erin', 'rating': 5, 'v': 1});
        toInsert.add({
          'game': 'Ticket To Ride',
          'player': 'Dallas',
          'rating': 4,
          'v': 1
        });
        toInsert.add({
          'game': 'Ticket To Ride',
          'player': 'Anthony',
          'rating': 2,
          'v': 1
        });

        // Avg 4.5 with 4 ratings (counting only highest v)
        toInsert
            .add({'game': 'Dominion', 'player': 'Paul', 'rating': 5, 'v': 2});
        toInsert
            .add({'game': 'Dominion', 'player': 'Erin', 'rating': 4, 'v': 1});
        toInsert
            .add({'game': 'Dominion', 'player': 'Dallas', 'rating': 4, 'v': 1});
        toInsert.add(
            {'game': 'Dominion', 'player': 'Anthony', 'rating': 5, 'v': 1});

        // Avg 5 with 2 ratings
        toInsert
            .add({'game': 'Pandemic', 'player': 'Erin', 'rating': 5, 'v': 1});
        toInsert
            .add({'game': 'Pandemic', 'player': 'Dallas', 'rating': 5, 'v': 1});

        await collection.insertMany(toInsert);

        // Avg player ratings
        // Dallas = 3, Anthony 3.5, Paul = 4, Erin = 4.25
/* We want equivalent of this when used on the mongo shell.
 * (Should be able to just copy and paste below once test is run and failed once)
db.runCommand(
{ aggregate : "testAggregate", pipeline : [
{"$group": {
      "_id": { "game": "$game", "player": "$player" },
      "rating": { "$sum": "$rating" } } },
{"$group": {
        "_id": "$_id.game",
        "avgRating": { "$avg": "$rating" } } },
{ "$sort": { "_id": 1 } }
]});
 */
        var pipeline = <Map<String, Object>>[];
        var p1 = {
          r'$group': {
            '_id': {'game': r'$game', 'player': r'$player'},
            'rating': {r'$sum': r'$rating'}
          }
        };
        var p2 = {
          r'$group': {
            '_id': r'$_id.game',
            'avgRating': {r'$avg': r'$rating'}
          }
        };
        var p3 = {
          r'$sort': {'_id': 1}
        };

        pipeline.add(p1);
        pipeline.add(p2);
        pipeline.add(p3);

        expect(p1['\u0024group'], isNotNull);
        expect(p1[r'$group'], isNotNull);

        var aggregateOperation =
            AggregateOperation(pipeline, collection: collection);
        var v = await aggregateOperation.execute();
        var cursor = v[keyCursor] as Map;
        var result = cursor[keyFirstBatch] as List;
        expect(result.first[key_id], 'Age of Steam');
        expect(result.first['avgRating'], 3);
      });

      test('Aggregate With Cursor Batch Size', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var toInsert = <Map<String, dynamic>>[];

        // Avg 1 with 1 rating
        toInsert.add({
          'game': 'At the Gates of Loyang',
          'player': 'Dallas',
          'rating': 1,
          'v': 1
        });

        // Avg 3 with 1 rating
        toInsert.add(
            {'game': 'Age of Steam', 'player': 'Paul', 'rating': 3, 'v': 1});

        // Avg 2 with 2 ratings
        toInsert.add({'game': 'Fresco', 'player': 'Erin', 'rating': 3, 'v': 1});
        toInsert
            .add({'game': 'Fresco', 'player': 'Dallas', 'rating': 1, 'v': 1});

        // Avg 3.5 with 4 ratings
        toInsert.add(
            {'game': 'Ticket To Ride', 'player': 'Paul', 'rating': 4, 'v': 1});
        toInsert.add(
            {'game': 'Ticket To Ride', 'player': 'Erin', 'rating': 5, 'v': 1});
        toInsert.add({
          'game': 'Ticket To Ride',
          'player': 'Dallas',
          'rating': 4,
          'v': 1
        });
        toInsert.add({
          'game': 'Ticket To Ride',
          'player': 'Anthony',
          'rating': 2,
          'v': 1
        });

        // Avg 4.5 with 4 ratings (counting only highest v)
        toInsert
            .add({'game': 'Dominion', 'player': 'Paul', 'rating': 5, 'v': 2});
        toInsert
            .add({'game': 'Dominion', 'player': 'Erin', 'rating': 4, 'v': 1});
        toInsert
            .add({'game': 'Dominion', 'player': 'Dallas', 'rating': 4, 'v': 1});
        toInsert.add(
            {'game': 'Dominion', 'player': 'Anthony', 'rating': 5, 'v': 1});

        // Avg 5 with 2 ratings
        toInsert
            .add({'game': 'Pandemic', 'player': 'Erin', 'rating': 5, 'v': 1});
        toInsert
            .add({'game': 'Pandemic', 'player': 'Dallas', 'rating': 5, 'v': 1});

        await collection.insertMany(toInsert);

        // Avg player ratings
        // Dallas = 3, Anthony 3.5, Paul = 4, Erin = 4.25
/* We want equivalent of this when used on the mongo shell.
 * (Should be able to just copy and paste below once test is run and failed once)
db.runCommand(
{ aggregate : "testAggregate", pipeline : [
{"$group": {
      "_id": { "game": "$game", "player": "$player" },
      "rating": { "$sum": "$rating" } } },
{"$group": {
        "_id": "$_id.game",
        "avgRating": { "$avg": "$rating" } } },
{ "$sort": { "_id": 1 } }
]});
 */
        var pipeline = <Map<String, Object>>[];
        var p1 = {
          r'$group': {
            '_id': {'game': r'$game', 'player': r'$player'},
            'rating': {r'$sum': r'$rating'}
          }
        };
        var p2 = {
          r'$group': {
            '_id': r'$_id.game',
            'avgRating': {r'$avg': r'$rating'}
          }
        };
        var p3 = {
          r'$sort': {'_id': 1}
        };

        pipeline.add(p1);
        pipeline.add(p2);
        pipeline.add(p3);

        expect(p1['\u0024group'], isNotNull);
        expect(p1['\$group'], isNotNull);

        var aggregateOperation = AggregateOperation(pipeline,
            collection: collection, cursor: {'batchSize': 3});
        var v = await aggregateOperation.execute();
        final cursor = v[keyCursor] as Map;
        expect(cursor['id'], const TypeMatcher<int>());
        final firstBatch = cursor[keyFirstBatch] as List;
        expect(firstBatch.length, 3);
        expect(firstBatch.first[key_id], 'Age of Steam');
        expect(firstBatch.first['avgRating'], 3);
      });

      test('Aggregate To Stream', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        var toInsert = <Map<String, dynamic>>[];

        // Avg 1 with 1 rating
        toInsert.add({
          'game': 'At the Gates of Loyang',
          'player': 'Dallas',
          'rating': 1,
          'v': 1
        });

        // Avg 3 with 1 rating
        toInsert.add(
            {'game': 'Age of Steam', 'player': 'Paul', 'rating': 3, 'v': 1});

        // Avg 2 with 2 ratings
        toInsert.add({'game': 'Fresco', 'player': 'Erin', 'rating': 3, 'v': 1});
        toInsert
            .add({'game': 'Fresco', 'player': 'Dallas', 'rating': 1, 'v': 1});

        // Avg 3.5 with 4 ratings
        toInsert.add(
            {'game': 'Ticket To Ride', 'player': 'Paul', 'rating': 4, 'v': 1});
        toInsert.add(
            {'game': 'Ticket To Ride', 'player': 'Erin', 'rating': 5, 'v': 1});
        toInsert.add({
          'game': 'Ticket To Ride',
          'player': 'Dallas',
          'rating': 4,
          'v': 1
        });
        toInsert.add({
          'game': 'Ticket To Ride',
          'player': 'Anthony',
          'rating': 2,
          'v': 1
        });

        // Avg 4.5 with 4 ratings (counting only highest v)
        toInsert
            .add({'game': 'Dominion', 'player': 'Paul', 'rating': 5, 'v': 2});
        toInsert
            .add({'game': 'Dominion', 'player': 'Erin', 'rating': 4, 'v': 1});
        toInsert
            .add({'game': 'Dominion', 'player': 'Dallas', 'rating': 4, 'v': 1});
        toInsert.add(
            {'game': 'Dominion', 'player': 'Anthony', 'rating': 5, 'v': 1});

        // Avg 5 with 2 ratings
        toInsert
            .add({'game': 'Pandemic', 'player': 'Erin', 'rating': 5, 'v': 1});
        toInsert
            .add({'game': 'Pandemic', 'player': 'Dallas', 'rating': 5, 'v': 1});

        await collection.insertMany(toInsert);

        // Avg player ratings
        // Dallas = 3, Anthony 3.5, Paul = 4, Erin = 4.25
/* We want equivalent of this when used on the mongo shell.
 * (Should be able to just copy and paste below once test is run and failed once)
db.runCommand(
{ aggregate : "testAggregate", pipeline : [
{"$group": {
      "_id": { "game": "$game", "player": "$player" },
      "rating": { "$sum": "$rating" } } },
{"$group": {
        "_id": "$_id.game",
        "avgRating": { "$avg": "$rating" } } },
{ "$sort": { "_id": 1 } }
]});
 */
        var pipeline = <Map<String, Object>>[];
        var p1 = {
          r'$group': {
            key_id: {'game': r'$game', 'player': r'$player'},
            'rating': {r'$sum': r'$rating'}
          }
        };
        var p2 = {
          r'$group': {
            key_id: r'$_id.game',
            'avgRating': {r'$avg': r'$rating'}
          }
        };
        var p3 = {
          r'$sort': {key_id: 1}
        };

        pipeline.add(p1);
        pipeline.add(p2);
        pipeline.add(p3);

        expect(p1['\u0024group'], isNotNull);
        expect(p1[r'$group'], isNotNull);
        // set batchSize parameter to split response to 2 chunks
        /*   var aggregate = await collection
            .aggregateToStream(pipeline,
                cursorOptions: {'batchSize': 1}, allowDiskUse: true)
            .toList(); */
        var cursor = ModernCursor(AggregateOperation(pipeline,
            collection: collection, cursor: {'batchSize': 1}));
        var aggregate = await cursor.stream.toList();

        expect(aggregate.isNotEmpty, isTrue);
        expect(aggregate.first[key_id], 'Age of Steam');
        expect(aggregate.first['avgRating'], 3);
      });
    }, skip: cannotRunTests);

    tearDownAll(() async {
      await db.open();
      await Future.forEach(usedCollectionNames,
          (String collectionName) => db.collection(collectionName).drop());
      await db.close();
    });
  });

  group('Change Stream', () {
    var cannotRunTests = false;
    var isStandalone = false;
    setUp(() async {
      await initializeDatabase();
      if (db.masterConnection == null ||
          !db.masterConnection.serverCapabilities.supportsOpMsg) {
        cannotRunTests = true;
      }
      if (db.masterConnection != null &&
          db.masterConnection.serverCapabilities.isStandalone) {
        isStandalone = true;
      }
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    test('Simple change from collection with changeStream', () async {
      var collectionName = getRandomCollectionName();
      /*   var resultMap = await db.createCollection(collectionName,
          createCollectionOptions:
              CreateCollectionOptions(capped: true, size: 5242880, max: 5000));
      expect(resultMap[keyOk], 1.0); */
      var collection = db.collection(collectionName);
      await insertManyDocuments(collection, 3);

      var pipeline =
          AggregationPipelineBuilder() /* .addStage(Group(
          id: 'games',
          fields: {'total': Sum(Field('cost')), 'avg': Avg(Field('cost'))})) */
          ;

      //List<Map<String, Object>> pipeMap = pipeline.build();
      //pipeMap.insert(0, {aggregateChangeStream: {}});
      var cursor =
          ModernCursor(ChangeStreamOperation(pipeline, collection: collection));
      var stream = cursor.changeStream;

      var gotFourth = false;
      var gotFifth = false;

      if (isStandalone) {
        expect(() async {
          await for (var event in stream) {
            print(event.serverResponse['a']);
          }
        }, throwsMongoDartError);
        return;
      }

      var aResult = 3;
      var controller = stream.listen((changeEvent) {
        Map fullDocument = changeEvent.fullDocument;
        expect(fullDocument['a'], aResult++);

        if (fullDocument['a'] == 3) {
          expect(changeEvent.isInsert, isTrue);
          gotFourth = true;
        } else if (fullDocument['a'] == 4) {
          expect(changeEvent.isInsert, isTrue);
          gotFifth = true;
        }
      });

      expect(cursor.state, State.INIT);

      await Future.delayed(Duration(seconds: 2));

      await collection.insertOne({'a': 3});

      await Future.doWhile(() async {
        if (gotFifth) {
          await controller.cancel();
          return false;
        } else if (gotFourth) {
          gotFourth = false;
          controller.pause();
          await collection.insertOne({'a': 4});
        }
        await Future.delayed(Duration(seconds: 1));
        if (controller.isPaused) {
          controller.resume();
        }

        return true;
      });
      expect(cursor.state, State.CLOSED);
    }, skip: cannotRunTests);

    test('Change with match from collection with changeStream', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);
      await insertManyDocuments(collection, 3);

      var pipeline =
          /* <Map<String, Object>>[
        <String, Object>{
          r'$match': {
            'fullDocument.a': {r'$ne': 15}
          }
        }
      ]; */
          AggregationPipelineBuilder()
              .addStage(Match(where.lt('fullDocument.a', 15).map['\$query']));

      var cursor =
          ModernCursor(ChangeStreamOperation(pipeline, collection: collection));
      var stream = cursor.changeStream;

      var gotFourth = false;
      var gotFifth = false;

      if (isStandalone) {
        expect(() async {
          await for (var event in stream) {
            print(event.serverResponse['a']);
          }
        }, throwsMongoDartError);
        return;
      }

      var aResult = 3;
      var controller = stream.listen((changeEvent) {
        Map fullDocument = changeEvent.fullDocument;

        expect(fullDocument['a'], aResult++);

        if (fullDocument['a'] == 3) {
          expect(changeEvent.isInsert, isTrue);
          gotFourth = true;
        } else if (fullDocument['a'] == 4) {
          expect(changeEvent.isInsert, isTrue);
          gotFifth = true;
        }
      });

      expect(cursor.state, State.INIT);

      await Future.delayed(Duration(seconds: 2));

      await collection.insertOne({'a': 3}, writeConcern: WriteConcern.MAJORITY);

      await Future.doWhile(() async {
        if (gotFifth) {
          await controller.cancel();
          return false;
        } else if (gotFourth) {
          gotFourth = false;
          controller.pause();
          await collection.insertOne({'a': 4});
        }
        await Future.delayed(Duration(seconds: 1));
        if (controller.isPaused) {
          controller.resume();
        }

        return true;
      });

      expect(cursor.state, State.CLOSED);
    }, skip: cannotRunTests);

    test('Change with match from collection.watch()', () async {
      var collectionName = getRandomCollectionName();
      var collection = db.collection(collectionName);
      await insertManyDocuments(collection, 3);

      var pipeline = AggregationPipelineBuilder()
          .addStage(Match(where.lt('fullDocument.a', 15).map['\$query']));

      var stream = collection.watch(pipeline);

      var gotFourth = false;
      var gotFifth = false;

      if (isStandalone) {
        expect(() async {
          await for (var event in stream) {
            print(event.serverResponse['a']);
          }
        }, throwsMongoDartError);
        return;
      }

      var aResult = 3;
      var controller = stream.listen((changeEvent) {
        Map fullDocument = changeEvent.fullDocument;

        expect(fullDocument['a'], aResult++);

        if (fullDocument['a'] == 3) {
          expect(changeEvent.isInsert, isTrue);
          gotFourth = true;
        } else if (fullDocument['a'] == 4) {
          expect(changeEvent.isInsert, isTrue);
          gotFifth = true;
        }
      });

      await Future.delayed(Duration(seconds: 2));

      await collection.insertOne({'a': 3}, writeConcern: WriteConcern.MAJORITY);

      await Future.doWhile(() async {
        if (gotFifth) {
          await controller.cancel();
          return false;
        } else if (gotFourth) {
          gotFourth = false;
          controller.pause();
          await collection.insertOne({'a': 4});
        }
        await Future.delayed(Duration(seconds: 1));
        if (controller.isPaused) {
          controller.resume();
        }

        return true;
      });
    }, skip: cannotRunTests);

    tearDownAll(() async {
      await db.open();
      await Future.forEach(usedCollectionNames,
          (String collectionName) => db.collection(collectionName).drop());
      await db.close();
    });
  });

  group('Count', () {
    var cannotRunTests = false;
    setUp(() async {
      await initializeDatabase();
      if (db.masterConnection == null ||
          !db.masterConnection.serverCapabilities.supportsOpMsg) {
        cannotRunTests = true;
      }
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    group('Command', () {
      test('All documents - Map result', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany(<Map<String, dynamic>>[
          {'game': 'At the Gates of Loyang', 'cost': Rational.parse('15.20')},
          {'game': 'Age of Steam', 'cost': Rational.parse('16.80')},
          {'game': 'Fresco', 'cost': Rational.parse('13')}
        ]);

        var operation = CountOperation(collection);

        var result = await operation.execute();

        expect(result[keyOk], 1.0);
        expect(result[keyN], 3);
      }, skip: cannotRunTests);
      test('All documents - Class result', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany(<Map<String, dynamic>>[
          {'game': 'At the Gates of Loyang', 'cost': Rational.parse('15.20')},
          {'game': 'Age of Steam', 'cost': Rational.parse('16.80')},
          {'game': 'Fresco', 'cost': Rational.parse('13')}
        ]);

        var operation = CountOperation(collection);

        var result = await operation.executeDocument();

        expect(result.ok, 1.0);
        expect(result.count, 3);
      }, skip: cannotRunTests);
      test('Selected documents - Class result', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany(<Map<String, dynamic>>[
          {'game': 'At the Gates of Loyang', 'cost': Rational.parse('15.20')},
          {'game': 'Age of Steam', 'cost': Rational.parse('16.80')},
          {'game': 'Fresco', 'cost': Rational.parse('13')}
        ]);

        var operation = CountOperation(collection,
            query: where.gt('cost', Rational.fromInt(15)).map[key$Query]);

        var result = await operation.executeDocument();

        expect(result.ok, 1.0);
        expect(result.count, 2);
      }, skip: cannotRunTests);
      test('Skip documents and majority read concern - Class result', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany(<Map<String, dynamic>>[
          {'game': 'At the Gates of Loyang', 'cost': Rational.parse('15.20')},
          {'game': 'Age of Steam', 'cost': Rational.parse('16.80')},
          {'game': 'Fresco', 'cost': Rational.parse('13')}
        ]);

        var operation = CountOperation(collection,
            // It seems that skip does not work with a selection
            //query: where.gt('cost', Rational.fromInt(15)).map[key$Query],
            skip: 1,
            countOptions: CountOptions(
                readConcern: ReadConcern(ReadConcernLevel.majority)));

        var result = await operation.executeDocument();

        expect(result.ok, 1.0);
        expect(result.count, 2);
      }, skip: cannotRunTests);

      tearDownAll(() async {
        await db.open();
        await Future.forEach(usedCollectionNames,
            (String collectionName) => db.collection(collectionName).drop());
        await db.close();
      });
    });
  });

  group('Distinct', () {
    var cannotRunTests = false;
    var running3_6 = false;
    var isReplicaSet = false;
    var isSharded = false;
    setUp(() async {
      await initializeDatabase();
      if (db.masterConnection == null ||
          !db.masterConnection.serverCapabilities.supportsOpMsg) {
        cannotRunTests = true;
      }
      var serverFcv = db?.masterConnection?.serverCapabilities?.fcv ?? '0.0';
      if (serverFcv.compareTo('3.6') == 0) {
        running3_6 = true;
      }
      isReplicaSet =
          db?.masterConnection?.serverCapabilities?.isReplicaSet ?? false;
      isSharded =
          db?.masterConnection?.serverCapabilities?.isShardedCluster ?? false;
    });

    tearDown(() async {
      await cleanupDatabase();
    });

    group('Command', () {
      test('Return Distinct Values for a Field - Map result', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany(<Map<String, dynamic>>[
          {
            '_id': 1,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'red'},
            'sizes': ['S', 'M']
          },
          {
            '_id': 2,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'blue'},
            'sizes': ['M', 'L']
          },
          {
            '_id': 3,
            'dept': 'B',
            'item': {'sku': '222', 'color': 'blue'},
            'sizes': 'S'
          },
          {
            '_id': 4,
            'dept': 'A',
            'item': {'sku': '333', 'color': 'black'},
            'sizes': ['S']
          }
        ]);

        var operation = DistinctOperation(collection, 'dept');

        var result = await operation.execute();

        expect(result[keyOk], 1.0);
        expect(result[keyValues], isNotNull);
        expect((result[keyValues] as List).length, 2);
        expect((result[keyValues] as List).first, 'A');
        expect((result[keyValues] as List).last, 'B');
      }, skip: cannotRunTests);

      test('Return Distinct Values for a Field - Class result', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany(<Map<String, dynamic>>[
          {
            '_id': 1,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'red'},
            'sizes': ['S', 'M']
          },
          {
            '_id': 2,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'blue'},
            'sizes': ['M', 'L']
          },
          {
            '_id': 3,
            'dept': 'B',
            'item': {'sku': '222', 'color': 'blue'},
            'sizes': 'S'
          },
          {
            '_id': 4,
            'dept': 'A',
            'item': {'sku': '333', 'color': 'black'},
            'sizes': ['S']
          }
        ]);

        var operation = DistinctOperation(collection, 'dept');

        var result = await operation.executeDocument();

        expect(result.ok, 1.0);
        expect(result.values, isNotNull);
        expect(result.values.length, 2);
        expect(result.values.first, 'A');
        expect(result.values.last, 'B');
      }, skip: cannotRunTests);

      test('Return Distinct Values for an Embedded Field - Class result',
          () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany(<Map<String, dynamic>>[
          {
            '_id': 1,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'red'},
            'sizes': ['S', 'M']
          },
          {
            '_id': 2,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'blue'},
            'sizes': ['M', 'L']
          },
          {
            '_id': 3,
            'dept': 'B',
            'item': {'sku': '222', 'color': 'blue'},
            'sizes': 'S'
          },
          {
            '_id': 4,
            'dept': 'A',
            'item': {'sku': '333', 'color': 'black'},
            'sizes': ['S']
          }
        ]);

        var operation = DistinctOperation(collection, 'item.sku');

        var result = await operation.executeDocument();

        expect(result.ok, 1.0);
        expect(result.values, isNotNull);
        expect(result.values.length, 3);
        expect(result.values.first, '111');
        expect(result.values.last, '333');
      }, skip: cannotRunTests);

      test('Return Distinct Values for an Array Field - Class result',
          () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany(<Map<String, dynamic>>[
          {
            '_id': 1,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'red'},
            'sizes': ['S', 'M']
          },
          {
            '_id': 2,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'blue'},
            'sizes': ['M', 'L']
          },
          {
            '_id': 3,
            'dept': 'B',
            'item': {'sku': '222', 'color': 'blue'},
            'sizes': 'S'
          },
          {
            '_id': 4,
            'dept': 'A',
            'item': {'sku': '333', 'color': 'black'},
            'sizes': ['S']
          }
        ]);

        var operation = DistinctOperation(collection, 'sizes');

        var result = await operation.executeDocument();

        expect(result.ok, 1.0);
        expect(result.values, isNotNull);
        expect(result.values.length, 3);
        if (running3_6 && !isSharded) {
          expect(result.values.first, 'M');
          expect(result.values.last, 'L');
        } else {
          expect(result.values.first, 'L');
          expect(result.values.last, 'S');
        }
      }, skip: cannotRunTests);

      test(
          'Selection with Distinct Values for an Embedded Field - Class result',
          () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany(<Map<String, dynamic>>[
          {
            '_id': 1,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'red'},
            'sizes': ['S', 'M']
          },
          {
            '_id': 2,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'blue'},
            'sizes': ['M', 'L']
          },
          {
            '_id': 3,
            'dept': 'B',
            'item': {'sku': '222', 'color': 'blue'},
            'sizes': 'S'
          },
          {
            '_id': 4,
            'dept': 'A',
            'item': {'sku': '333', 'color': 'black'},
            'sizes': ['S']
          }
        ]);

        var operation =
            DistinctOperation(collection, 'item.sku', query: {'dept': 'A'});
        var result = await operation.executeDocument();

        expect(result.ok, 1.0);
        expect(result.values, isNotNull);
        expect(result.values.length, 2);
        expect(result.values.first, '111');
        expect(result.values.last, '333');
      }, skip: cannotRunTests);
      test('Specify a collation - Class result', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await insertFrenchCafe(collection);

        var operation = DistinctOperation(collection, 'category',
            distinctOptions: DistinctOptions(
                collation: CollationOptions('fr', strength: 1)));
        var result = await operation.executeDocument();

        expect(result.ok, 1.0);
        expect(result.values, isNotNull);
        expect(result.values.length, 1);
        expect(result.values.first, 'café');
      }, skip: cannotRunTests);

      tearDownAll(() async {
        await db.open();
        await Future.forEach(usedCollectionNames,
            (String collectionName) => db.collection(collectionName).drop());
        await db.close();
      });
    });

    group('Collection helper', () {
      test('Return Distinct Values for a Field - Map result', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany(<Map<String, dynamic>>[
          {
            '_id': 1,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'red'},
            'sizes': ['S', 'M']
          },
          {
            '_id': 2,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'blue'},
            'sizes': ['M', 'L']
          },
          {
            '_id': 3,
            'dept': 'B',
            'item': {'sku': '222', 'color': 'blue'},
            'sizes': 'S'
          },
          {
            '_id': 4,
            'dept': 'A',
            'item': {'sku': '333', 'color': 'black'},
            'sizes': ['S']
          }
        ]);

        var result = await collection.modernDistinctMap('dept');

        expect(result[keyOk], 1.0);
        expect(result[keyValues], isNotNull);
        expect((result[keyValues] as List).length, 2);
        expect((result[keyValues] as List).first, 'A');
        expect((result[keyValues] as List).last, 'B');
      }, skip: cannotRunTests);

      test('Return Distinct Values for a Field - Class result', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany(<Map<String, dynamic>>[
          {
            '_id': 1,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'red'},
            'sizes': ['S', 'M']
          },
          {
            '_id': 2,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'blue'},
            'sizes': ['M', 'L']
          },
          {
            '_id': 3,
            'dept': 'B',
            'item': {'sku': '222', 'color': 'blue'},
            'sizes': 'S'
          },
          {
            '_id': 4,
            'dept': 'A',
            'item': {'sku': '333', 'color': 'black'},
            'sizes': ['S']
          }
        ]);

        var result = await collection.modernDistinct('dept');

        expect(result.ok, 1.0);
        expect(result.values, isNotNull);
        expect(result.values.length, 2);
        expect(result.values.first, 'A');
        expect(result.values.last, 'B');
      }, skip: cannotRunTests);

      test('Return Distinct Values for an Embedded Field - Class result',
          () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany(<Map<String, dynamic>>[
          {
            '_id': 1,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'red'},
            'sizes': ['S', 'M']
          },
          {
            '_id': 2,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'blue'},
            'sizes': ['M', 'L']
          },
          {
            '_id': 3,
            'dept': 'B',
            'item': {'sku': '222', 'color': 'blue'},
            'sizes': 'S'
          },
          {
            '_id': 4,
            'dept': 'A',
            'item': {'sku': '333', 'color': 'black'},
            'sizes': ['S']
          }
        ]);

        var result = await collection.modernDistinct('item.sku');

        expect(result.ok, 1.0);
        expect(result.values, isNotNull);
        expect(result.values.length, 3);
        expect(result.values.first, '111');
        expect(result.values.last, '333');
      }, skip: cannotRunTests);

      test('Return Distinct Values for an Array Field - Class result',
          () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany(<Map<String, dynamic>>[
          {
            '_id': 1,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'red'},
            'sizes': ['S', 'M']
          },
          {
            '_id': 2,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'blue'},
            'sizes': ['M', 'L']
          },
          {
            '_id': 3,
            'dept': 'B',
            'item': {'sku': '222', 'color': 'blue'},
            'sizes': 'S'
          },
          {
            '_id': 4,
            'dept': 'A',
            'item': {'sku': '333', 'color': 'black'},
            'sizes': ['S']
          }
        ]);

        var operation = DistinctOperation(collection, 'sizes');

        var result = await operation.executeDocument();

        expect(result.ok, 1.0);
        expect(result.values, isNotNull);
        expect(result.values.length, 3);
        if (running3_6 && !isSharded) {
          expect(result.values.first, 'M');
          expect(result.values.last, 'L');
        } else {
          expect(result.values.first, 'L');
          expect(result.values.last, 'S');
        }
      }, skip: cannotRunTests);

      test(
          'Selection with Distinct Values for an Embedded Field - Class result',
          () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await collection.insertMany(<Map<String, dynamic>>[
          {
            '_id': 1,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'red'},
            'sizes': ['S', 'M']
          },
          {
            '_id': 2,
            'dept': 'A',
            'item': {'sku': '111', 'color': 'blue'},
            'sizes': ['M', 'L']
          },
          {
            '_id': 3,
            'dept': 'B',
            'item': {'sku': '222', 'color': 'blue'},
            'sizes': 'S'
          },
          {
            '_id': 4,
            'dept': 'A',
            'item': {'sku': '333', 'color': 'black'},
            'sizes': ['S']
          }
        ]);

        var result =
            await collection.modernDistinct('item.sku', query: {'dept': 'A'});

        expect(result.ok, 1.0);
        expect(result.values, isNotNull);
        expect(result.values.length, 2);
        expect(result.values.first, '111');
        expect(result.values.last, '333');
      }, skip: cannotRunTests);
      test('Specify a collation - Class result', () async {
        var collectionName = getRandomCollectionName();
        var collection = db.collection(collectionName);

        await insertFrenchCafe(collection);

        var result = await collection.modernDistinct('category',
            distinctOptions: DistinctOptions(
                collation: CollationOptions('fr', strength: 1)));

        expect(result.ok, 1.0);
        expect(result.values, isNotNull);
        expect(result.values.length, 1);
        expect(result.values.first, 'café');
      }, skip: cannotRunTests);

      tearDownAll(() async {
        await db.open();
        await Future.forEach(usedCollectionNames,
            (String collectionName) => db.collection(collectionName).drop());
        await db.close();
      });
    });
  });
}
