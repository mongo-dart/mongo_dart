#library("domain_model");
#import("../../lib/objectory/ObjectoryLib_vm.dart");
interface Author extends IPersistent default ObjectoryFactory {
  Author();
  String name;
  int age;
  String email;
}
interface Person extends IPersistent default ObjectoryFactory {
  Person();
  String firstName;
  String lastName;
  Date birthday;
  Address address;  
  Person father;
  Person mother;
  List<Person> children;
}
interface Address extends IPersistent default ObjectoryFactory {
  Address();
  String cityName;
  String zipcode;
  String streetName;
}
interface Customer extends IPersistent default ObjectoryFactory {
  Customer();
  String name;
  List<Address> addresses; 
}

class AuthorImpl extends RootPersistentObject implements Author {  
  String get type()=>'Author';
  set name(String value){
    if (value is String){
      value = value.toUpperCase();
    }      
    setProperty('name', value);
  }
  String get name()=>getProperty('name');
}
class PersonImpl extends RootPersistentObject implements Person {  
  String get type()=>"Person";
  init(){
    address = new Address();
    children = new PersistentList([]);
  }
}
class CustomerImpl extends RootPersistentObject implements Customer {  
  String get type()=>"Customer";
  init(){
    addresses = new PersistentList([]);    
  }
}  

class AddressImpl extends InnerPersistentObject implements Address {  
  String get type()=>"Address";
}
class ObjectoryFactory{
  factory Author() => new AuthorImpl();
  factory Person() => new PersonImpl();
  factory Address() => new AddressImpl();
  factory Customer() => new CustomerImpl();
}
void registerClasses() {
  ClassSchema schema;
  schema = new ClassSchema('Author',()=>new Author());
  schema.addProperty(new PropertySchema("name", "String"));
  schema.addProperty(new PropertySchema("age", "String"));
  schema.addProperty(new PropertySchema("email", "String"));
  objectory.registerClass(schema);
  
  schema = new ClassSchema('Address',()=>new Address());
  schema.addProperty(new PropertySchema("cityName", "String"));
  schema.addProperty(new PropertySchema("zipCode", "String"));
  schema.addProperty(new PropertySchema("streetName", "String"));
  objectory.registerClass(schema); 

  schema = new ClassSchema('Person',()=>new Person());
  schema.addProperty(new PropertySchema("firstName", "String"));
  schema.addProperty(new PropertySchema("lastName", "String"));
  schema.addProperty(new PropertySchema("birthday", "Date"));
  schema.addProperty(new PropertySchema("address", "Address",internalObject: true));  
  schema.addProperty(new PropertySchema("father", "Person",externalRef: true));
  schema.addProperty(new PropertySchema("mother", "Person",externalRef: true));
  schema.addProperty(new PropertySchema("children", "Person",externalRef: true, collection: true));
  objectory.registerClass(schema); 

  schema = new ClassSchema('Customer',()=>new Customer());
  schema.addProperty(new PropertySchema("name", "String"));
  schema.addProperty(new PropertySchema("addresses", "Address",internalObject: true, collection: true));  
  objectory.registerClass(schema); 
  
}
final PERSON = 'Person';
final AUTHOR = 'Author';
final ADDRESS = 'Address';
final CUSTOMER = 'Customer';