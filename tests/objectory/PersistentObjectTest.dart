#library("PersistenObjectTests");
#import("../../lib/objectory/ObjectoryLib_vm.dart");
#import('../../third_party/testing/unittest/unittest_vm.dart');
#source("author.dart");
testAuthorCreation(){
  Author author = new Author();
  author.name = 'vadim';
  author.age = 99;
  author.email = 'sdf';
  expect(author.getKeys()[0]).equals("name");
  expect(author.getKeys()[1]).equals("age");
  expect(author.getKeys().last()).equals("email");
  expect(author.getKeys().length).equals(3);
  expect(author.name).equals('VADIM'); // converted to uppercase by custom  setter;
}
testSetDirty(){
  Author author = new Author();
  author.name = "Vadim";
  expect(author.dirtyFields.length).equals(1);
  expect(author.isDirty()).isTrue();  
}

main(){
  group("PersistenObjectTests", ()  {
    test("testAuthorCreation",testAuthorCreation);
    test("testSetDirty",testSetDirty);
  });  

}