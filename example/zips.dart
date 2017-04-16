import 'package:mongo_dart/mongo_dart.dart';

//////Sample is broken now. Mongolab free accounts upgraded to MongoDb 3.0
///// and support for 3.0 default authentication scheme not implemented yet
main() async {
  void displayZip(Map zip) {
    print(
        'state: ${zip["state"]}, city: ${zip["city"]}, zip: ${zip["id"]}, population: ${zip["pop"]}');
  }

  Db db =
      new Db("mongodb://reader:vHm459fU@ds037468.mongolab.com:37468/samlple");
  var zips = db.collection('zip');
  await db.open();
  print('''
******************** Zips for state NY, with population between 14000 and 16000,
******************** reverse ordered by population''');
  await zips
      .find(where
          .eq('state', 'NY')
          .inRange('pop', 14000, 16000)
          .sortBy('pop', descending: true))
      .forEach(displayZip);
  print('\n******************** Find ZIP for code 78829 (BATESVILLE)');
  var batesville = await zips.findOne(where.eq('id', '78829'));
  displayZip(batesville);
  print('******************** Find 10 ZIP closest to BATESVILLE');
  await zips
      .find(where.near('loc', batesville["loc"]).limit(10))
      .forEach(displayZip);
  print('closing db');
  await db.close();
}
