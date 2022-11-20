import 'package:mongo_dart/mongo_dart_old.dart';
import 'package:mongo_dart/src/mongo_client.dart';
import 'package:mongo_dart/src/parameters/write_concern.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  var client = MongoClient(defaultUri);
  await client.connect();
  var db = client.db();

  Future cleanupDatabase() async {
    await client.close();
  }

  var collectionName = 'create-collection-schema';
  await db.dropCollection(collectionName);
  var resultMap = await db.createCollection(collectionName,
      createCollectionOptions: CreateCollectionOptions(validator: {
        r'$jsonSchema': {
          'bsonType': 'object',
          'required': ['phone'],
          'properties': {
            'phone': {
              'bsonType': 'string',
              'description': 'must be a string and is required'
            },
            'email': {
              'bsonType': 'string',
              'pattern': r'@mongodb\.com$',
              'description':
                  'must be a string and match the regular expression pattern'
            },
            'status': {
              'enum': ['Unknown', 'Incomplete'],
              'description': 'can only be one of the enum values'
            }
          }
        }
      }));

  if (resultMap[keyOk] != 1.0) {
    print(resultMap[keyErrmsg]);
    await cleanupDatabase();
    return;
  }
  var collection = db.collection(collectionName);

  var ret = await collection.insertOne(
      {'name': 'Anand', 'phone': '451 3874643', 'status': 'Incomplete'},
      writeConcern: WriteConcern.majority);

  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }

  ret = await collection.insertOne({'name': 'Amanda', 'status': 'Updated'},
      writeConcern: WriteConcern.majority);

  if (!ret.isSuccess) {
    print(ret.writeError?.errmsg);
  }

  await cleanupDatabase();
}
