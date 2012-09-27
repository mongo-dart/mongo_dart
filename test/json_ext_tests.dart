#library("tests");
#import('package:unittest/unittest.dart');
#import('dart:scalarlist');
#import('package:mongo_dart/bson.dart');
#import('package:mongo_dart/src/bson/json_ext.dart');

main(){
  group('JsonExt Date:', (){
    test('Simple date stringify',(){
      expect(JsonExt.stringify(new Date.fromMillisecondsSinceEpoch(30)),'{"\$date":30}');
    });
    test('Simple date parse',(){
      expect(JsonExt.parse('{"\$date":30}'),new Date.fromMillisecondsSinceEpoch(30));
    });
    test('Date deep in object',(){
      var date = new Date.now();
      var article = {'title': 'Article 1', 'comments': [{'body': 'First comment','date': date}, {'body':'Second comment', 'date': date}]};
      Map articleRetrieved = JsonExt.parse(JsonExt.stringify(article));
      expect(articleRetrieved['comments'][0]['date'],date);
    });
    group('JsonExt ObjectId:', (){
      test('Simple ObjectId stringify',(){
        expect(JsonExt.stringify(new ObjectId.fromHexString("AAAA")),'{"\$oid":"AAAA"}');
      });
      test('Simple ObjectId parse',(){                 
        expect((JsonExt.parse('{"\$oid":"AAAAAAAAAAAAAAAAAAAAAAAA"}') as ObjectId).toHexString() ,"AAAAAAAAAAAAAAAAAAAAAAAA");
      });
    });    
  });    
}