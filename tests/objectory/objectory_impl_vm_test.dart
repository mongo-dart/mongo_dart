#library("ObjectoryVM");
#import("../../lib/objectory/objectory_direct_connection_impl.dart");
#import("../../lib/objectory/objectory_base.dart");
#import("../../lib/objectory/persistent_object.dart");
#import("../../lib/objectory/objectory_query_builder.dart");
#import("../../lib/objectory/schema.dart");
#import("../../lib/bson/bson.dart");
#import('../../third_party/unittest/unittest.dart');
#import("domain_model.dart");

void testInsertionAndUpdate(){
  initDomainModel().then((_) {
    Author author = new Author();  
    author.name = 'Dan';
    author.age = 3;
    author.email = 'who@cares.net';
    author.save();
    author.age = 4;
    author.save();
    objectory.find($Author).then((coll){
      expect(coll.length,1);
      Author authFromMongo = coll[0];
      expect(authFromMongo.age,4);
      objectory.close();      
      callbackDone();
    });
  });
}
testCompoundObject(){
  initDomainModel().then((_) {  
    var person = new Person();
    person.address.cityName = 'Tyumen';
    person.address.streetName = 'Elm';  
    person.firstName = 'Dick';
    person.save();
    objectory.findOne($Person.id(person.id)).then((savedPerson){
      expect(savedPerson.firstName,'Dick');
      expect(savedPerson.address.streetName,'Elm');
      expect(savedPerson.address.cityName,'Tyumen');
      objectory.close();
      callbackDone();
    });        
  });
}
testObjectWithExternalRefs(){
  initDomainModel().then((_) {
    Person father = new Person();  
    father.firstName = 'Father';
    father.save();    
    Person son = new Person();  
    son.firstName = 'Son';
    son.father = father;
    son.save();    
    objectory.findOne($Person.id(son.id)).then((sonFromObjectory){
      // Links must be fetched before use.
      Expect.throws(()=>sonFromObjectory.father.firstName);      
      expect(sonFromObjectory.mother,isNull);
      sonFromObjectory.fetchLinks().then((__){  
        expect(sonFromObjectory.father.firstName,"Father");
        expect(sonFromObjectory.mother,isNull);
        objectory.close();
        callbackDone();
      });    
    });
  });  
}
testObjectWithCollectionOfExternalRefs(){
  Person father;
  Person son;
  Person daughter;
  Person sonFromObjectory;
  initDomainModel().chain((_) {
    father = new Person();  
    father.firstName = 'Father';
    father.save();
    son = new Person();  
    son.firstName = 'Son';
    son.father = father;
    son.save();
    daughter = new Person();
    daughter.father = father;
    daughter.firstName = 'daughter';
    daughter.save();
    father.children.add(son);
    father.children.add(daughter);
    father.save();
    return objectory.findOne($Person.id(father.id));
  }).chain((fatherFromObjectory){
      // Links must be fetched before use.   
    expect(fatherFromObjectory.children.length,2);    
    expect(()=>father.children[0],throws);      
    return father.fetchLinks();
  }).chain((_) {
    sonFromObjectory = father.children[0];  
    expect(sonFromObjectory.mother,isNull);
    return sonFromObjectory.fetchLinks();
  }).then((_){
    expect(sonFromObjectory.father.firstName,"Father");
    expect(sonFromObjectory.mother,isNull);
    objectory.close();
    callbackDone();
  });
}

testMap2ObjectWithListtOfInternalObjectsWithExternalRefs() {  
  User joe;
  User lisa;
  Author author;
  initDomainModel().chain((_) {    
    author = new Author();
    author.name = 'Vadim';
    author.save();
    joe = new User();
    joe.login = 'joe';
    joe.name = 'Joe Great';
    joe.save();
    lisa = new User();
    lisa.login = 'lisa';
    lisa.name = 'Lisa Fine';
    lisa.save();    
    var article = new Article();
    article.title = 'My first article';
    article.body = "It's been a hard days night";
    var comment = new Comment();
    comment.body = 'great article, dude';
    comment.user = joe;    
    article.comments.add(comment);
    article.author = author;
    comment = new Comment();
    comment.body = 'It is lame, sweety';
    comment.user = lisa;    
    article.comments.add(comment);
    objectory.save(article);
    return objectory.findOne($Article.sortBy('title'));
  }).chain((artcl) {
    expect(artcl.comments[0] is PersistentObject);    
    for (var each in artcl.comments) {
      expect(each is PersistentObject);     
    }
    expect(()=>artcl.comments[0].user,throws);
    return artcl.fetchLinks();
    
  }).then((artcl) {
    expect(artcl.comments[0].user.name,'Joe Great');
    expect(artcl.comments[1].user.name,'Lisa Fine');
    expect(artcl.author.name,'VADIM');
    objectory.close();
    callbackDone();
  });
}

testPropertyNameChecks() {
  var query = $Person.eq('firstName', 'Vadim');
  expect({'firstName': 'Vadim'},recursivelyMatches(query.map));
  expect(() => $Person.eq('unkwnownProperty', null),throws);
  query = $Person.eq('address.cityName', 'Tyumen');
  expect({'address.cityName': 'Tyumen'},recursivelyMatches(query.map));
  expect(() => $Person.eq('address.cityName1', 'Tyumen'),throws);
}

main(){    
  group("ObjectoryVM", () {        
    asyncTest("testInsertionAndUpdate",1,testInsertionAndUpdate);
    asyncTest("testCompoundObject",1,testCompoundObject);                  
    asyncTest("testObjectWithExternalRefs",1,testObjectWithExternalRefs);    
    asyncTest("testObjectWithCollectionOfExternalRefs",1,testObjectWithCollectionOfExternalRefs);
    asyncTest("testMap2ObjectWithListtOfInternalObjectsWithExternalRefs",1,testMap2ObjectWithListtOfInternalObjectsWithExternalRefs);
  });
  group("ObjectoryQuery", ()  {    
    test("testPropertyNameChecks",testPropertyNameChecks);
  });  
}