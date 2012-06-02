#library("ObjectoryVM");
#import("../../lib/objectory/ObjectoryLib_vm.dart");
#import('../../third_party/unittest/unittest.dart');
#source("domain_model.dart");
#source("../../lib/helpers/selector_builder.dart");
#source("../../lib/helpers/map_proxy.dart");
List futures;
Future<bool> setUpObjectory(){
  var res = new Completer();
//  objectory.clearFactories();
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
testNewInstanceMethod(){
  setUpObjectory().then((_) {  
    Author author = objectory.newInstance('Author');
    expect(author is Author).isTrue();
    objectory.close();
  });       
}
testMap2ObjectMethod(){
  setUpObjectory().then((_) {  
    Map map = {
      "name": "Vadim",
      "age": 300,
      "email": "nobody@know.it"};
    Author author = objectory.map2Object("Author",map);
    //Not converted to upperCase because setter has not been invoked
    expect(author.name).equals("Vadim"); 
    expect(author.age).equals(300);
    expect(author.email).equals("nobody@know.it");
    map = {
      "streetName": "333",
      "cityName": "44444"
        };
    Address address = objectory.map2Object("Address",map);  
    expect(address.cityName).equals("44444");
    objectory.close();
  });  
}
testCompoundObject(){
  setUpObjectory().then((_) {  
    Person person = new Person();  
    person.address.cityName = 'Tyumen';
    person.address.streetName = 'Elm';  
    person.firstName = 'Dick';
    objectory.save(person);
    objectory.findOne(PERSON,query().id(person.id)).then((savedPerson){
      expect(savedPerson.firstName).equals('Dick');
      expect(savedPerson.address.streetName).equals('Elm');
      expect(savedPerson.address.cityName).equals('Tyumen');
      objectory.close();
      callbackDone();
    });        
  });
}
testObjectWithLinks(){
  setUpObjectory().then((_) {
    Person father = new Person();  
    father.firstName = 'Father';
    objectory.save(father);
    Person son = new Person();  
    son.firstName = 'Son';
    son.father = father;
    objectory.save(son);  
    objectory.findOne(PERSON,query().id(son.id)).then((sonFromObjectory){
      // Links must be fetched before use.
      Expect.throws(()=>sonFromObjectory.father.firstName);
      expect(sonFromObjectory.mother).equals(null);
      sonFromObjectory.fetchLinks().then((_){
        expect(sonFromObjectory.father.firstName).equals("Father");
        expect(sonFromObjectory.mother).equals(null);
        objectory.close();
        callbackDone();
      });    
    });
  });  
}
main(){    
  group("ObjectoryVM", () { 
    asyncTest("testCompoundObject",1,testCompoundObject);   
    asyncTest("testInsertionAndUpdate",1,testInsertionAndUpdate);         
    asyncTest("testObjectWithLinks",1,testObjectWithLinks);               
    test("testNewInstanceMethod",testNewInstanceMethod);   
    test("testMap2ObjectMethod",testMap2ObjectMethod);
  });
}