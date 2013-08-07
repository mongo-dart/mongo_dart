#Mongo-dart - MongoDB driver for Dart programming language.

[![Build Status](https://drone.io/vadimtsushko/mongo_dart/status.png)](https://drone.io/vadimtsushko/mongo_dart/latest)

It is a server-side driver library for MongoDb implemented in pure Dart.

Simple usage example on base of [JSON ZIPS dataset] (http://media.mongodb.org/zips.json)


    import 'package:mongo_dart/mongo_dart.dart';
    main(){
      void displayZip(Map zip) {
        print('state: ${zip["state"]}, city: ${zip["city"]}, zip: ${zip["id"]}, population: ${zip["pop"]}'    );
      }
      Db db = new Db("mongodb://reader:vHm459fU@ds037468.mongolab.com:37468/samlple");
      var zips = db.collection('zip');
      db.open().then((_){
        print('''
    ******************** Zips for state NY, with population between 14000 and 16000,
    ******************** reverse ordered by population''');
        return zips.find(
            where.eq('state','NY').inRange('pop',14000,16000).sortBy('pop', descending: true))
              .forEach(displayZip);
      }).then((_) {
        print('\n******************** Find ZIP for code 78829 (BATESVILLE)');
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

###See also:

- [API Doc](http://vadimtsushko.github.com/mongo_dart/)

- [Feature check list](https://github.com/vadimtsushko/mongo_dart/blob/master/doc/feature_checklist.md)

- [Recent change notes](https://github.com/vadimtsushko/mongo_dart/blob/master/doc/change_notes.md)

- Additional [examples](https://github.com/vadimtsushko/mongo_dart/tree/master/example) and [tests](https://github.com/vadimtsushko/mongo_dart/tree/master/test)

- For more structured approach to communication with MongoDB: [Objectory](https://github.com/vadimtsushko/objectory)