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
      print("[${user.login}]:[${user.name}]:[${user.email}]");
      print(user);
      users[user.login] = user;
    }
    print("===================================================================================");
    print(">> Adding articles");
    var article = new Article();
    article.title = 'Caminando por Buenos Aires';
    article.body = 'Las callecitas de Buenos Aires tienen ese no se que...';
    article.author = authors['Jorge Luis Borges'];
//    objectory.save(article);

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
    
/*    User joe = new User();
    joe.login = 'joe';
    joe.name = 'Joe Great';
    objectory.save(joe);
    User lisa = new User();
    lisa.login = 'lisa';
    lisa.name = 'Lisa Fine';
    objectory.save(lisa);
    var article = new Article();
    article.author = authors['Jorge Luis Borges'];
    article.title = 'My first article';
    article.body = "It's been a hard days night";
    var comment = new Comment();
    comment.body = 'great article, dude';
    comment.user = joe;    
    article.comments.add(comment);
    comment = new Comment();
    comment.body = 'It is lame, sweety';
    comment.user = lisa;    
    article.comments.add(comment);
    objectory.save(article);
*/    
//    return objectory.findOne(ARTICLE);
    
    return objectory.findOne(ARTICLE);  
  }).chain((article){    
    var futures = new List();
    print("===================================================================================");
    print(">> Printing articles");
  //  var article = articles[0];
    //for (var article in articles) {
//      var completer = new Completer();
    print(article.comments[0] is IPersistent);    
    for (var each in article.comments) {
      print(each is IPersistent);     
    }
//    Expect.throws(()=>article.comments[0].user);
    

   return article.fetchLinks();
  }).then((article) {
        print("${article.author.name}:${article.title}:${article.body}");
        for (var comment in article.comments) {
          print("     ${comment.user.name}: ${comment.body}");
        }
      //  completer.complete(true);

    //  futures.add(completer.future);  
//    }
//    return Futures.wait(futures);
//  }).then((articles) {      
    objectory.close();
  });      
}