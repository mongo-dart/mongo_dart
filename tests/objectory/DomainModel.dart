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
  init(){
    setPropertyList(["name","age","email"]);
  }
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
    setPropertyList(["firstName","lastName","birthday","address"]);
    address = new Address();
  }
}  
class Address extends InnerPersistentObject implements IAddress{  
  String get type()=>"Address";
  init(){
    setPropertyList(["cityName","zipCode","streetName"]);
  }
}
