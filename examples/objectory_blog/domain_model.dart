#library("domain_model");
#import("../../lib/objectory/objectory_base.dart");
#import("../../lib/objectory/objectory_direct_connection_impl.dart");
#import("../../lib/objectory/persistent_object.dart");
#import("../../lib/objectory/objectory_query_builder.dart");
#import("../../lib/objectory/schema.dart");
#import("../../lib/bson/bson.dart");

interface Author extends PersistentObject default ObjectoryFactory {
  Author();
  String name;
  int age;
  String email;
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

interface Comment extends PersistentObject default ObjectoryFactory{
  Comment();
  User user;  
  String body;
  Date date;
}

class AuthorImpl extends RootPersistentObject implements Author {  
  String get type() => 'Author';  
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

class ObjectoryFactory{
  factory Author() => new AuthorImpl();
  factory User() => new UserImpl();
  factory Article() => new ArticleImpl();
  factory Comment() => new CommentImpl();  
}

void registerClasses() {
  ClassSchema schema;
  schema = new ClassSchema('Author',() => new Author());
  schema.addProperty(new PropertySchema("name", "String"));
  schema.addProperty(new PropertySchema("age", "String"));
  schema.addProperty(new PropertySchema("email", "String"));
  objectory.registerClass(schema);
  
  schema = new ClassSchema('User',() => new User());
  schema.addProperty(new PropertySchema("name", "String"));
  schema.addProperty(new PropertySchema("login", "String"));
  schema.addProperty(new PropertySchema("email", "String"));
  objectory.registerClass(schema);

  schema = new ClassSchema('Article',() => new Article());
  schema.addProperty(new PropertySchema("title", "String"));
  schema.addProperty(new PropertySchema("body", "String"));
  schema.addProperty(new PropertySchema("author", "Author",link: true));
  schema.addProperty(new PropertySchema("comments", "Comment",embeddedObject: true, collection: true, hasLinks: true));
  objectory.registerClass(schema); 

  schema = new ClassSchema('Comment',() => new Comment());
  schema.addProperty(new PropertySchema("date", "Date"));
  schema.addProperty(new PropertySchema("user", "User",link: true));  
  schema.addProperty(new PropertySchema("title", "String"));
  schema.addProperty(new PropertySchema("body", "String"));
  objectory.registerClass(schema); 
  
}

Future<bool> initDomainModel(){
  return setUpObjectory('ObjectoryBlog', registerClasses, dropDb: true);
}

ObjectoryQueryBuilder get $Author() => new ObjectoryQueryBuilder('Author');
ObjectoryQueryBuilder get $User() => new ObjectoryQueryBuilder('User');
ObjectoryQueryBuilder get $Article() => new ObjectoryQueryBuilder('Article');
