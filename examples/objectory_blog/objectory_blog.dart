#import("../../lib/objectory/ObjectoryLib_vm.dart");
#import("domain_model.dart");

Future<bool> setUpObjectory(){
  var res = new Completer();
  objectory.open("ObjectoryBlog").then((_){    
    objectory.dropDb();
    registerClasses();
    res.complete(true);
  });    
  return res.future;
}

main(){
  var authors = new Map<String,Author>();
  var users = new Map<String,User>();  
  setUpObjectory().chain((_) {
    print("===================================================================================");
    print(">> Adding Authors");
    var author = new Author();
    author.name = 'William Shakespeare';
    author.email = 'william@shakespeare.com';
    author.age = 587;
    objectory.save(author);
    author = new Author();
    author.name = 'Jorge Luis Borges';
    author.email = 'jorge@borges.com';
    author.age = 123;
    objectory.save(author);    
    return objectory.find(AUTHOR);
  }).chain((auths){  
    print("===================================================================================");
    print(">> Authors ordered by age ascending");
    for (var auth in auths) {
      authors[auth.name] = auth;
      print("[${auth.name}]:[${auth.email}]:[${auth.age}]");
    }
    print("===================================================================================");
    print(">> Adding Users");
    var user = new User();
    user.name = 'John Doe';
    user.login = 'jdoe';
    user.email = 'john@doe.com';
    objectory.save(user);
    user = new User();
    user.name = 'Lucy Smith';
    user.login = 'lsmith';
    user.email = 'lucy@smith.com';
    objectory.save(user);
    return objectory.find(USER);
  }).chain((usrs){  
    print("===================================================================================");
    print(">> >> Users ordered by login ascending");
    for (var user in usrs) {
      print("${user.login}]:[${user.name}]:[${user.email}");      
      users[user.login] = user;
    }
    print("===================================================================================");
    print(">> Adding articles");
    var article = new Article();
    article.title = 'Caminando por Buenos Aires';
    article.body = 'Las callecitas de Buenos Aires tienen ese no se que...';
    article.author = authors['Jorge Luis Borges'];
    objectory.save(article);

    article = new Article();
    article.title = 'I must have seen thy face before';
    article.body = 'Thine eyes call me in a new way';
    article.author = authors['William Shakespeare'];
    var comment = new Comment();
    comment.body = "great article!";
    comment.user = users['jdoe'];
    print("user = ${comment.user}");
    article.comments.add(comment);
    objectory.save(article);    
    return objectory.find(ARTICLE);  
  }).chain((articles){    
    var futures = new List();
    print("===================================================================================");
    print(">> Printing articles");    
    for (var article in articles) {
      var completer = new Completer();
      article.fetchLinks().then((_) {
        print("${article.author.name}:${article.title}:${article.body}");
        for (var comment in article.comments) {
          print("     ${comment.user.name}: ${comment.body}");
        }
        completer.complete(true);
      });
      futures.add(completer.future);  
    }
    return Futures.wait(futures);
  }).then((art) {
    objectory.close();
  });      
}