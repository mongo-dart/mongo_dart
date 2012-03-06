#import("dart:io");
main(){  
  Completer c = new Completer();
  new Timer((timer){c.complete('Tra');},4000);

  var f  = c.future; 
  //c.complete('Tra');
  waitFor(f){    
    f.then((v){return v;});
  }  
  print(waitFor(f));
}