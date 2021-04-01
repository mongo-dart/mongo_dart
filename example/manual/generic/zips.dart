import 'package:mongo_dart/mongo_dart.dart';

import 'zip_list.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const DefaultUri = 'mongodb://$dbAddress:27017/$dbName';

void displayZip(Map zip) {
  print('state: ${zip['state']}, city: ${zip['city']}, '
      'zip: ${zip['_id']}, population: ${zip['pop']}');
}

void main() async {
  var db = Db(DefaultUri);
  await db.open();

  Future cleanupDatabase() async => await db.close();

  if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
    return;
  }

  var collectionName = 'zip';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  print('Starting inserting data');
  var ret = await collection.insertMany(zipList);

  print('Creating geospatial index');
  await collection.createIndex(keys: {'loc': '2d'});

  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }
  print('''
******************** Zips for state NY, with population between 14000 and 16000,
******************** reverse ordered by population''');
  await collection
      .find(where
          .eq('state', 'NY')
          .inRange('pop', 14000, 16000)
          .sortBy('pop', descending: true))
      .forEach(displayZip);
  print('\n******************** Find ZIP for code 78829 (BATESVILLE)');
  var batesville = await collection.findOne(where.eq('_id', '78829'));
  if (batesville != null) {
    displayZip(batesville);
    print('******************** Find 10 ZIP closest to BATESVILLE');
    await collection
        .find(where.near('loc', batesville['loc']).limit(10))
        .forEach(displayZip);
  }

  await cleanupDatabase();
}
