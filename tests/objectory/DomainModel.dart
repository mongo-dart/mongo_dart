interface Author extends IPersistent default ObjectoryFactory{
  Author();
  String name;
  int age;
  String email;
}
interface Person extends IPersistent default ObjectoryFactory{
  Person();
  String firstName;
  String lastName;
  Date birthday;
  Address address;  
  Person father;
  Person mother;
}
interface Address extends IPersistent default ObjectoryFactory{
  Address();
  String cityName;
  String zipcode;
  String streetName;
}


class AuthorImpl extends RootPersistentObject implements Author{  
  String get type()=>'Author';
  set name(String value){
    if (value is String){
      value = value.toUpperCase();
    }      
    setProperty('name', value);
  }
  String get name()=>getProperty('name');
}
class PersonImpl extends RootPersistentObject implements Person{  
  String get type()=>"Person";
  init(){
    address = new Address();
  }
}  
class AddressImpl extends InnerPersistentObject implements Address{  
  String get type()=>"Address";
}
class ObjectoryFactory{
  factory Author()=>new AuthorImpl();
  factory Person()=>new PersonImpl();
  factory Address()=>new AddressImpl();
}
void registerClasses(){
  objectory.registerClass(new ClassSchema('Author',
      ()=>new Author(),
      ["name","age","email"]));
  objectory.registerClass(new ClassSchema('Address',
    ()=>new Address(),
    ["cityName","zipCode","streetName"]));
  objectory.registerClass(new ClassSchema('Person',
    ()=>new Person(),
    ["firstName","lastName","birthday"],
    components: {"address": "Address"},
    links: {"father": "Person", "mother": "Person"}));
}
final PERSON = 'Person';
final AUTHOR = 'Author';
final ADDRESS = 'Address';