#library("ObjectoryBaseImplTest");
#import("../../lib/objectory/ObjectoryLib_vm.dart");
#import('../../third_party/testing/unittest/unittest_vm.dart');
#source("author.dart");
setUpObjectory(){
  objectory.registerClass('Author',()=>new Author());
}
testNewInstanceMethod(){
  Author author = objectory.newInstance('Author');
  expect(author is Author).isTrue();
  print(author);
}
testMap2ObjectMethod(){
  Map map = {
    "name": "Vadim",
    "age": 300,
    "email": "nobody@know.it"};
  Author author = objectory.map2Object("Author",map);
  // Not converted to upperCase because setter has not been invoked
  expect(author.name).equals("Vadim"); 
  expect(author.age).equals(300);
  expect(author.email).equals("nobody@know.it");
}

main(){  
  setUpObjectory();
  group("ObjectoryTests", ()  {
    test("testNewInstanceMethod",testNewInstanceMethod);   
    test("testMap2ObjectMethod",testMap2ObjectMethod);       
  });  
}