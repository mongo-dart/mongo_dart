#library("ObjectoryVM");
#import("../../lib/objectory/ObjectoryLib_vm.dart");
#import('../../third_party/unittest/unittest.dart');
#import("domain_model.dart");
Future<bool> setUpObjectory(){
  var res = new Completer();
  objectory.open("ObjectoryTest").then((_){    
    objectory.dropDb();
    registerClasses();
    res.complete(true);
  });    
  return res.future;
}

void testInsertionAndUpdate(){
  setUpObjectory().then((_) {
    Author author = new Author();  
    author.name = 'Dan';
    author.age = 3;
    author.email = 'who@cares.net';  
    objectory.save(author); // First insert;
    author.age = 4;
    objectory.save(author); // Then update;
    objectory.find(AUTHOR).then((coll){
      expect(coll.length).equals(1);
      Author authFromMongo = coll[0];
      expect(authFromMongo.age).equals(4);
      objectory.close();      
      callbackDone();
    });
  });
}
testCompoundObject(){
  setUpObjectory().then((_) {  
    Person person = new Person();  
    person.address.cityName = 'Tyumen';
    person.address.streetName = 'Elm';  
    person.firstName = 'Dick';
    objectory.save(person);
    objectory.findOne(PERSON, {"_id": person.id}).then((savedPerson){
      expect(savedPerson.firstName).equals('Dick');
      expect(savedPerson.address.streetName).equals('Elm');
      expect(savedPerson.address.cityName).equals('Tyumen');
      objectory.close();
      callbackDone();
    });        
  });
}
testObjectWithExternalRefs(){
  setUpObjectory().then((_) {
    Person father = new Person();  
    father.firstName = 'Father';
    objectory.save(father);
    Person son = new Person();  
    son.firstName = 'Son';
    son.father = father;
    objectory.save(son);
    
    objectory.findOne(PERSON, {"_id": son.id}).then((sonFromObjectory){
      // Links must be fetched before use.
      Expect.throws(()=>sonFromObjectory.father.firstName);      
      expect(sonFromObjectory.mother).equals(null);
      sonFromObjectory.fetchLinks().then((__){  
        expect(sonFromObjectory.father.firstName).equals("Father");
        expect(sonFromObjectory.mother).equals(null);
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
  setUpObjectory().chain((_) {
    father = new Person();  
    father.firstName = 'Father';
    objectory.save(father);
    son = new Person();  
    son.firstName = 'Son';
    son.father = father;
    objectory.save(son);
    daughter = new Person();
    daughter.father = father;
    daughter.firstName = 'daughter';
    objectory.save(daughter);
    father.children.add(son);
    father.children.add(daughter);
    objectory.save(father);
    return objectory.findOne(PERSON, {"_id": father.id});
  }).chain((fatherFromObjectory){
      // Links must be fetched before use.   
    expect(fatherFromObjectory.children.length).equals(2);    
    Expect.throws(()=>father.children[0]);      
    return father.fetchLinks();
  }).chain((_) {
    sonFromObjectory = father.children[0];  
    expect(sonFromObjectory.mother).equals(null);
    return sonFromObjectory.fetchLinks();
  }).then((_){
    expect(sonFromObjectory.father.firstName).equals("Father");
    expect(sonFromObjectory.mother).equals(null);
    objectory.close();
    callbackDone();
  });
}

testMap2ObjectWithListtOfInternalObjectsWithExternalRefs() {  
  User joe;
  User lisa;
  Author author;
  setUpObjectory().chain((_) {
    author = new Author();
    author.name = 'Vadim';
    objectory.save(author);
    joe = new User();
    joe.login = 'joe';
    joe.name = 'Joe Great';
    objectory.save(joe);
    lisa = new User();
    lisa.login = 'lisa';
    lisa.name = 'Lisa Fine';
    objectory.save(lisa);
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
    return objectory.findOne(ARTICLE);
  }).chain((artcl) {
    expect(artcl.comments[0] is PersistentObject).isTrue();    
    for (var each in artcl.comments) {
      expect(each is PersistentObject).isTrue();     
    }
    Expect.throws(()=>artcl.comments[0].user);
    return artcl.fetchLinks();
    
  }).then((artcl) {
    expect(artcl.comments[0].user.name).equals('Joe Great');
    expect(artcl.comments[1].user.name).equals('Lisa Fine');
    expect(artcl.author.name).equals('VADIM');
    objectory.close();
    callbackDone();
  });
}


main(){    
  group("ObjectoryVM", () {        
    asyncTest("testInsertionAndUpdate",1,testInsertionAndUpdate);
    asyncTest("testCompoundObject",1,testCompoundObject);                  
    asyncTest("testObjectWithExternalRefs",1,testObjectWithExternalRefs);    
    asyncTest("testObjectWithCollectionOfExternalRefs",1,testObjectWithCollectionOfExternalRefs);
    asyncTest("testMap2ObjectWithListtOfInternalObjectsWithExternalRefs",1,testMap2ObjectWithListtOfInternalObjectsWithExternalRefs);
  });
}