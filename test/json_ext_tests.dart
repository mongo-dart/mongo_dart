library JSON_EXT_ext_tests;
import 'package:unittest/unittest.dart';
import 'dart:scalarlist';
import 'package:mongo_dart/mongo_dart.dart';


main(){
  initBsonPlatform();
  group('JSON_EXT Date:', (){
    test('Simple date stringify',(){
      expect(JSON_EXT.stringify(new Date.fromMillisecondsSinceEpoch(30)),'{"\$date":30}');
    });
    test('Simple date parse',(){
      expect(JSON_EXT.parse('{"\$date":30}'),new Date.fromMillisecondsSinceEpoch(30));
    });
    test('Date deep in object',(){
      var date = new Date.now();
      var article = {'title': 'Article 1', 'comments': [{'body': 'First comment','date': date}, {'body':'Second comment', 'date': date}]};
      Map articleRetrieved = JSON_EXT.parse(JSON_EXT.stringify(article));
      expect(articleRetrieved['comments'][0]['date'],date);
    });
  });
  group('JSON_EXT ObjectId:', (){
    test('Simple ObjectId stringify',(){
      expect(JSON_EXT.stringify(new ObjectId.fromHexString("AAAA")),'{"\$oid":"AAAA"}');
    });
    test('Simple ObjectId parse',(){
      expect((JSON_EXT.parse('{"\$oid":"AAAAAAAAAAAAAAAAAAAAAAAA"}') as ObjectId).toHexString() ,"AAAAAAAAAAAAAAAAAAAAAAAA");
    });
    test('ObjectId lifecycle native/JSON_EXT/bson/native',(){
      ObjectId originalOid = new ObjectId();
      ObjectId JSON_EXTOid = JSON_EXT.parse(JSON_EXT.stringify([originalOid]))[0];
      expect(JSON_EXTOid.toHexString(),originalOid.toHexString());
      var bson = new BSON();
      var b = bson.serialize({'oid':JSON_EXTOid});
      b.rewind();
      Map map = bson.deserialize(b);
      var targetOid = map['oid'];
      expect(targetOid.toHexString(),originalOid.toHexString());
    });
  });
  group('JSON_EXT DbRef:', (){
    test('Simple DbRef stringify',(){
      var id = new ObjectId();
      var dbRef = new DbRef('test',id);
      var js = JSON_EXT.stringify(dbRef);
      expect(js,'{"\$ref":"test","\$oid":"${id.toHexString()}"}');
    });
    test('Simple DbPointer parse',(){
      var id = new ObjectId();
      var dbRef = new DbRef('test',id);
      var dbRefParsed = JSON_EXT.parse(JSON_EXT.stringify(dbRef));
      expect(dbRefParsed,dbRef);
    });
  });
  group('JSON_EXT BsonRegexp:', (){
    test('Simple BsonRegexp stringify',(){
      var js = JSON_EXT.stringify(new BsonRegexp('test',options: 'mi'));
      expect(js,'{"\$regex":"test","\$options":"mi"}');
    });
    test('Simple DbPointer parse',(){
      var id = new ObjectId();
      var regex = new BsonRegexp('test',options: 'mi');
      var regexParsed = JSON_EXT.parse(JSON_EXT.stringify(regex));
      expect(regexParsed.pattern,regexParsed.pattern);
      expect(regexParsed.options,regexParsed.options);
    });
  });

}