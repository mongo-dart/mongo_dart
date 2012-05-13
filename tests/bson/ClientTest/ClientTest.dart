#import('dart:html');

void main() {
  testUint8List();
  show('Hello, World!');
}

void testUint8List(){
  Uint8List bytes = new Uint8List(4);
}
void show(String message) {
  document.query('#status').innerHTML = message;
}
