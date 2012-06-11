#library("PersistenObjectTests");
#import("../../lib/objectory/objectory_vm.dart");
#import("../../lib/bson/bson.dart");
#import('../../third_party/unittest/unittest.dart');
#import("domain_model.dart");

testPropertyNameChecks() {
  var query = $Person.eq('firstName', 'Vadim');
  expect(query.map).equals({'firstName': 'Vadim'});
  Expect.throws(() => $Person.eq('unkwnownProperty', null));
  query = $Person.eq('address.cityName', 'Tyumen');
  expect(query.map).equals({'address.cityName': 'Tyumen'});
  Expect.throws(() => $Person.eq('address.cityName1', 'Tyumen'));
}
main(){
  registerClasses();  
  group("ObjectoryQuery", ()  {    
    test("testPropertyNameChecks",testPropertyNameChecks);
  });
}