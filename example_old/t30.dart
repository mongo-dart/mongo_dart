import 't30_1.dart';

/* class Fin2 extends Fin {
  Fin2(super.str);
  int? i;
} */
/* class Fin3 implements Fin {
  //Fin3(super.str);
} */
/* class Fin4 mixin Fin {
  //Fin4(super.str);
} */

class Bas2 extends Bas {
  Bas2(super.str);
}

/* class Bas3 implements Bas {
  Bas3(super.str);
} */

/* class Bas4 mixin Bas {
  Bas4(super.str);
} */

/* class Sel2 extends Sel {
  Sel2(super.str);
} */

void main() {
  var f = Fin('4');
  //var f2 = Fin2('5');
  //var s = Sel('3');
  var b = Bas('2');
  print('$f,  $b');
}
