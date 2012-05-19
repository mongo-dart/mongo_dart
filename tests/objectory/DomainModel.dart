interface IAuthor{
  String name;
  int age;
  String email;
}
interface IPerson{
  String firstName;
  String lastName;
  Date birthday;
  Address address;  
}
interface IAddress{
  String cityName;
  String zipcode;
  String streetName;
}


class Author extends RootPersistentObject implements IAuthor{  
  String get type()=>'Author';
  set name(String value){
    if (value is String){
      value = value.toUpperCase();
    }      
    setProperty('name', value);
  }
}
class Person extends RootPersistentObject implements IPerson{  
  String get type()=>"Person";
  init(){    
    address = new Address();
  }
}  
class Address extends InnerPersistentObject implements IAddress{  
  String get type()=>"Address";
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
    ["firstName","lastName","birthday","address"],
    links: {"address": "Address"}));
}