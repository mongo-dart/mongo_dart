#library("ObjectoryBaseImplTest");
#import("../../lib/objectory/ObjectoryLib_vm.dart");
#import('../../third_party/testing/unittest/unittest_vm.dart');
#source("author.dart");
Future<bool> setUpObjectory(){
  var res = new Completer();
  objectory.open("ObjectoryTest").then((_){
    objectory.registerClass('Author',()=>new Author());
    print("I'm here");
    res.complete(true);
  });    
  return res.future;
}
void testInsertion(){
  Author author = new Author();  
  author.name = 'Dan';
  author.age = 3;
  author.email = 'who@cares.net';
  objectory.save(author);
  objectory.find('Author').then((coll){
    for (Author auth in coll){
      print("Author: ${auth.id} ${auth.name} ${auth.age}");
    };
    callbackDone();
  });
}

main(){  
  setUpObjectory().then((_) {
    print("And now here. ${objectory.db}");
    group("ObjectoryTests", ()  {
      asyncTest("testInsertion",1,testInsertion);   
    });  
  });    
}