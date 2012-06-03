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
//      print(sonFromObjectory);
      expect(sonFromObjectory.mother).equals(null);
      sonFromObjectory.fetchLinks().then((_){
//        print(sonFromObjectory);
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
    print("1");
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
    print("2");
    return objectory.findOne(PERSON, {"_id": father.id});
  }).chain((fatherFromObjectory){
      // Links must be fetched before use.
    print("3");
    print(fatherFromObjectory);
    expect(fatherFromObjectory.children.length).equals(2);    
    print("4");
    sonFromObjectory = father.children[0];
    Expect.throws(()=>sonFromObjectory.father);      
    return father.fetchLinks();
  }).chain((_) {
    print("4");
    sonFromObjectory = father.children[0];
    expect(sonFromObjectory.mother).equals(null);
    expect(sonFromObjectory.father.id).equals(father.id);
    return sonFromObjectory.fetchLinks();
  }).then((_){
    expect(sonFromObjectory.father.firstName).equals("Father");
    expect(sonFromObjectory.mother).equals(null);
    objectory.close();
    callbackDone();
  });
}

main(){    
  group("ObjectoryVM", () {        
    asyncTest("testInsertionAndUpdate",1,testInsertionAndUpdate);
    asyncTest("testCompoundObject",1,testCompoundObject);                   
//    asyncTest("testObjectWithCollectionOfExternalRefs",1,testObjectWithCollectionOfExternalRefs);
    asyncTest("testObjectWithExternalRefs",1,testObjectWithExternalRefs);
//    asyncTest("testObjectWithCollectionOfExternalRefs",1,testObjectWithCollectionOfExternalRefs);    
  });
}