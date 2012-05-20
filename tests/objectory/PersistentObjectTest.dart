#library("PersistenObjectTests");
#import("../../lib/objectory/ObjectoryLib_vm.dart");
#import("../../lib/bson/bson.dart");
#import('../../third_party/testing/unittest/unittest_vm.dart');
#source("DomainModel.dart");
testAuthorCreation(){
  Author author = new Author();
  author.name = 'vadim';
  author.age = 99;
  author.email = 'sdf';
  expect(author.getKeys()[0]).equals("_id");
  expect(author.getKeys()[1]).equals("name");
  expect(author.getKeys()[2]).equals("age");
  expect(author.getKeys().last()).equals("email");
  expect(author.getKeys().length).equals(4);
  expect(author.name).equals('VADIM'); // converted to uppercase by custom  setter;
}

testSetDirty(){
  Author author = new Author();
  author.name = "Vadim";
  expect(author.dirtyFields.length).equals(1);
  expect(author.isDirty()).isTrue();  
}
testCompoundObject(){
  Person person = new Person();  
  person.address.cityName = 'Tyumen';
  person.address.streetName = 'Elm';  
  person.firstName = 'Dick';
  Map map = person.map;
  expect(map["address"]["streetName"]).equals("Elm");
  expect(person.address.parent).equals(person);
  expect(person.address.pathToMe).equals("address");
  expect(person.isDirty()).isTrue();
  expect(person.address.isDirty()).isTrue();
}
testFailOnSettingUnsavedLinkObject(){
  Person son = new Person();  
  Person father = new Person();  
  ;
  Expect.throws(()=>son.father = father,reason:"Link object must be saved (have ObjectId)");
}  
testFailOnAbsentProperty(){
  IAuthor author = new Author();
  Expect.throws(()=>author.sdfsdfsdfgdfgdf,reason:"Must fail on missing property getter");
}

main(){
  registerClasses();  
  group("PersistenObjectTests", ()  {
    test("testAuthorCreation",testAuthorCreation);
    test("testSetDirty",testSetDirty);
    test("testCompoundObject",testCompoundObject);
    test("testFailOnAbsentProperty",testFailOnAbsentProperty);
    test("testFailOnSettingUnsavedLinkObject",testFailOnSettingUnsavedLinkObject);    
  });  

}