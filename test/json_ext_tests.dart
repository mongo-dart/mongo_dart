library json_ext_tests;
import 'package:unittest/unittest.dart';
import 'dart:scalarlist';
import 'package:mongo_dart/bson.dart';
import 'package:mongo_dart/bson_vm.dart';
import 'package:mongo_dart/src/bson/json_ext.dart';

main(){
  initBsonPlatform();
  group('JsonExt Date:', (){
    test('Simple date stringify',(){
      expect(JSON.stringify(new Date.fromMillisecondsSinceEpoch(30)),'{"\$date":30}');
    });
    test('Simple date parse',(){
      expect(JSON.parse('{"\$date":30}'),new Date.fromMillisecondsSinceEpoch(30));
    });
    test('Date deep in object',(){
      var date = new Date.now();
      var article = {'title': 'Article 1', 'comments': [{'body': 'First comment','date': date}, {'body':'Second comment', 'date': date}]};
      Map articleRetrieved = JSON.parse(JSON.stringify(article));
      expect(articleRetrieved['comments'][0]['date'],date);
    });
  });    
  group('JsonExt ObjectId:', (){
    test('Simple ObjectId stringify',(){
      expect(JSON.stringify(new ObjectId.fromHexString("AAAA")),'{"\$oid":"AAAA"}');
    });
    test('Simple ObjectId parse',(){                 
      expect((JSON.parse('{"\$oid":"AAAAAAAAAAAAAAAAAAAAAAAA"}') as ObjectId).toHexString() ,"AAAAAAAAAAAAAAAAAAAAAAAA");
    });
    test('ObjectId lifecycle native/json/bson/native',(){
      ObjectId originalOid = new ObjectId();
      ObjectId jsonOid = JSON.parse(JSON.stringify([originalOid]))[0];        
      expect(jsonOid.toHexString(),originalOid.toHexString());
      var bson = new BSON();
      var b = bson.serialize({'oid':jsonOid});
      b.rewind();
      Map map = bson.deserialize(b);        
      var targetOid = map['oid'];        
      expect(targetOid.toHexString(),originalOid.toHexString());
    });      
  });
  group('JsonExt DbRef:', (){      
    test('Simple DbRef stringify',(){
      var id = new ObjectId();
      var dbRef = new DbRef('test',id);        
      var js = JSON.stringify(dbRef);      
      expect(js,'{"\$ref":"test","\$oid":"${id.toHexString()}"}');
    });      
    test('Simple DbPointer parse',(){
      var id = new ObjectId();
      var dbRef = new DbRef('test',id);
      var dbRefParsed = JSON.parse(JSON.stringify(dbRef));
      expect(dbRefParsed,dbRef);
    });
  });
  group('JsonExt BsonRegexp:', (){      
    test('Simple BsonRegexp stringify',(){              
      var js = JSON.stringify(new BsonRegexp('test',options: 'mi'));      
      expect(js,'{"\$regex":"test","\$options":"mi"}');
    });      
    test('Simple DbPointer parse',(){
      var id = new ObjectId();
      var regex = new BsonRegexp('test',options: 'mi');
      var regexParsed = JSON.parse(JSON.stringify(regex));
      expect(regexParsed.pattern,regexParsed.pattern);
      expect(regexParsed.options,regexParsed.options);
    });
  });      
  
}