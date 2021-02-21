import 'package:mongo_dart/mongo_dart.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const DefaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  Db db;
  var running4_2orGreater = false;

  Future initializeDatabase() async {
    db = Db(DefaultUri);
    await db.open();
    var serverFcv = db?.masterConnection?.serverCapabilities?.fcv ?? '0.0';
    if (serverFcv.compareTo('4.2') != -1) {
      running4_2orGreater = true;
    }
  }

  Future cleanupDatabase() async {
    await db.close();
  }

  await initializeDatabase();
  if (db.masterConnection == null ||
      !db.masterConnection.serverCapabilities.supportsOpMsg) {
    return;
  }
  if (!running4_2orGreater) {
    print('Not supported in this release');
    return;
  }

  var collectionName = 'find-modify-aggregation-pipeline';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  var ret = await collection.insertMany([
    {
      '_id': 1,
      'grades': [
        {'grade': 80, 'mean': 75, 'std': 6},
        {'grade': 85, 'mean': 90, 'std': 4},
        {'grade': 85, 'mean': 85, 'std': 6}
      ],
    },
    {
      '_id': 2,
      'grades': [
        {'grade': 90, 'mean': 75, 'std': 6},
        {'grade': 87, 'mean': 90, 'std': 3},
        {'grade': 85, 'mean': 85, 'std': 4}
      ]
    }
  ]);
  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }

  var res = await collection.modernFindAndModify(
    query: where.eq('_id', 1),
    update: AggregationPipelineBuilder()
        .addStage(AddFields({
          r'total': {r'$sum': r'$grades.grade'},
        }))
        .build(),
    returnNew: true,
  );
  print('Updated document: ${res.lastErrorObject.updatedExisting}'); // true

  print('Modified element new total: '
      '${res.value['total']}'); // 250;

  await cleanupDatabase();
}
