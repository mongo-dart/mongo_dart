#library("domain_model");
#import("../../lib/objectory/objectory_direct_connection_impl.dart");
#import("../../lib/objectory/objectory_base.dart");
#import("../../lib/objectory/persistent_object.dart");
#import("../../lib/objectory/objectory_query_builder.dart");
#import("../../lib/objectory/schema.dart");

interface Author extends PersistentObject default ObjectoryFactory {
  Author();
  String name;
  int age;
  String email;
}
interface Person extends PersistentObject default ObjectoryFactory {
  Person();
  String firstName;
  String lastName;
  Date birthday;
  Address address;  
  Person father;
  Person mother;
  List<Person> children;
}
interface Address extends PersistentObject default ObjectoryFactory {
  Address();
  String cityName;
  String zipcode;
  String streetName;
}
interface Customer extends PersistentObject default ObjectoryFactory {
  Customer();
  String name;
  List<Address> addresses; 
}

interface User extends PersistentObject default ObjectoryFactory {
  User();
  String name;
  String login;
  String email;
}

interface Article extends PersistentObject default ObjectoryFactory {
  Article();
  String title;
  String body;
  Author author;
  List<Comment> comments;
}

interface Comment extends PersistentObject default ObjectoryFactory {
  Comment();
  User user;  
  String body;
  Date date;
}

class UserImpl extends RootPersistentObject implements User {  
  String get type() => "User";
}

class ArticleImpl extends RootPersistentObject implements Article {
  String get type() => "Article";
}

class CommentImpl extends EmbeddedPersistentObject implements Comment {
  String get type() => "Comment";
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
}
class CustomerImpl extends RootPersistentObject implements Customer {  
  String get type()=>"Customer";
}  

class AddressImpl extends EmbeddedPersistentObject implements Address {  
  String get type()=>"Address";
}
class ObjectoryFactory{
  factory Author() => new AuthorImpl();
  factory Person() => new PersonImpl();
  factory Address() => new AddressImpl();
  factory Customer() => new CustomerImpl();
  factory User() => new UserImpl();
  factory Article() => new ArticleImpl();
  factory Comment() => new CommentImpl();  
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
  schema.addProperty(new PropertySchema("address", "Address",embeddedObject: true));  
  schema.addProperty(new PropertySchema("father", "Person",link: true));
  schema.addProperty(new PropertySchema("mother", "Person",link: true));
  schema.addProperty(new PropertySchema("children", "Person",hasLinks: true, collection: true));
  objectory.registerClass(schema); 

  schema = new ClassSchema('Customer',()=>new Customer());
  schema.addProperty(new PropertySchema("name", "String"));
  schema.addProperty(new PropertySchema("addresses", "Address",embeddedObject: true, collection: true));  
  objectory.registerClass(schema); 
  
  schema = new ClassSchema('User',()=>new User());
  schema.addProperty(new PropertySchema("name", "String"));
  schema.addProperty(new PropertySchema("login", "String"));
  schema.addProperty(new PropertySchema("email", "String"));
  objectory.registerClass(schema);

  schema = new ClassSchema('Article',()=>new Article());
  schema.addProperty(new PropertySchema("title", "String"));
  schema.addProperty(new PropertySchema("body", "String"));
  schema.addProperty(new PropertySchema("author", "Author",link: true));
  schema.addProperty(new PropertySchema("comments", "Comment",embeddedObject: true, collection: true, hasLinks: true));
  objectory.registerClass(schema); 

  schema = new ClassSchema('Comment',()=>new Comment());
  schema.addProperty(new PropertySchema("title", "String"));
  schema.addProperty(new PropertySchema("body", "String"));
  schema.addProperty(new PropertySchema("user", "User",link: true));
  objectory.registerClass(schema);  
  
}
Future<bool> initDomainModel(){
  return setUpObjectory('ObjectoryTests', registerClasses, dropDb: true);
}

ObjectoryQueryBuilder get $Person() => new ObjectoryQueryBuilder('Person');
ObjectoryQueryBuilder get $Author() => new ObjectoryQueryBuilder('Author');
ObjectoryQueryBuilder get $Customer() => new ObjectoryQueryBuilder('Customer');
ObjectoryQueryBuilder get $User() => new ObjectoryQueryBuilder('User');
ObjectoryQueryBuilder get $Article() => new ObjectoryQueryBuilder('Article');
