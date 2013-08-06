import 'package:mongo_dart/mongo_dart.dart';
main(){
  void displayZip(Map zip) {
    print('state: ${zip["state"]}, city: ${zip["city"]}, zip: ${zip["id"]}, population: ${zip["pop"]}');
  }
  Db db = new Db("mongodb://reader:vHm459fU@ds037468.mongolab.com:37468/samlple");
  var zips = db.collection('zip');
  db.open().then((_){
    print('******************** Zips for state NY, with population between 14000 and 16000, reverse ordered by population');
    return zips.find(
        where.eq('state','NY').inRange('pop',14000,16000).sortBy('pop', descending: true))
          .forEach(displayZip);
  }).then((_) {
    print('******************** Find ZIP for code 78829 (BATESVILLE)');
    return zips.findOne(where.eq('id','78829'));
  }).then((batesville) {
    displayZip(batesville);
    print('******************** Find 10 ZIP closest to BATESVILLE');
    return zips.find(
        where.near('loc',batesville["loc"]).limit(10))
          .forEach(displayZip);
  }).then((_) {
    print('closing db');
    db.close();
  });
}