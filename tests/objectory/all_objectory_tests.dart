#library("all_objectory_tests");
#import("objectory_impl_vm_test.dart",prefix:"impl");
#import("persistent_object_test.dart",prefix:"persistentObject");
main(){  
  impl.main();
  persistentObject.main();  
}