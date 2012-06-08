#library("domain_model");
#import("../../lib/objectory/ObjectoryLib_vm.dart");
interface Author extends IPersistent default ObjectoryFactory {
  Author();
  String name;
  int age;
  String email;
}
interface User extends IPersistent default ObjectoryFactory {
  User();
  String name;
  String login;
  String email;
}

interface Article extends IPersistent default ObjectoryFactory {
  Article();
  String title;
  String body;
  Author author;
  List<Comment> comments;
}

interface Comment extends IPersistent default ObjectoryFactory {
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
  init(){
    comments = new PersistentList([]);
  }
}

class CommentImpl extends InnerPersistentObject implements Comment {
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
  schema = new ClassSchema('Author',()=>new Author());
  schema.addProperty(new PropertySchema("name", "String"));
  schema.addProperty(new PropertySchema("age", "String"));
  schema.addProperty(new PropertySchema("email", "String"));
  objectory.registerClass(schema);
  
  schema = new ClassSchema('User',()=>new User());
  schema.addProperty(new PropertySchema("name", "String"));
  schema.addProperty(new PropertySchema("login", "String"));
  schema.addProperty(new PropertySchema("email", "String"));
  objectory.registerClass(schema);

  schema = new ClassSchema('Article',()=>new Article());
  schema.addProperty(new PropertySchema("title", "String"));
  schema.addProperty(new PropertySchema("body", "String"));
  schema.addProperty(new PropertySchema("author", "Author",externalRef: true));
  schema.addProperty(new PropertySchema("comments", "Comment",internalObject: true, collection: true, containExternalRef: true));
  objectory.registerClass(schema); 

  schema = new ClassSchema('Comment',()=>new Comment());
  schema.addProperty(new PropertySchema("title", "String"));
  schema.addProperty(new PropertySchema("body", "String"));
  schema.addProperty(new PropertySchema("user", "User",externalRef: true));
  objectory.registerClass(schema); 
  
}
final USER = 'User';
final AUTHOR = 'Author';
final ARTICLE = 'Article';
final COMMENT = 'Comment';