#import("domain_model.dart");
#import("dart:mirrors");
main() {
  var domainModelLib = currentMirrorSystem().libraries['domain_model'];  
  domainModelLib.classes.forEach((name,classMirror) {    
    if (classMirror.superinterfaces.length > 0 && classMirror.superinterfaces[0].simpleName == 'PersistentObject') {      
      print(classMirror.simpleName);
      classMirror.methods.forEach((name,field) {
        
        print(" field $name ${field.simpleName}");        
      });       
    }      
  });    
}