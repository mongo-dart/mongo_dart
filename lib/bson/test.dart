#import("dart:html");
main () {
  var list8 = new Uint8Array(8);
  var list16 = new Uint16Array.fromBuffer(list8);
  list16[0] = 3;
  print(list8); 
}