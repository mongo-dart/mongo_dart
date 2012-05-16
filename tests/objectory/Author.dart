interface IAuthor{
  String name;
  int age;
  String email;
}
class Author extends PersistentObject implements IAuthor{  
  String get type()=>'Author';
  set name(String value){
    if (value is String){
      value = value.toUpperCase();
    }      
    setProperty('name', value);
  }
  /*
  init(){
    name = null;
    age = null;
    email = null;
  }
  */
}