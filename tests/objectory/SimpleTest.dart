class C1{
  static final type = 1;
  static int getType(){
    return type;
  }
  C1(){}
  factory C1.c2(){
    return new C2();
  }
}
class C2 extends C1{
  static final type = 2;
}
main(){
  print(C1.getType());
  C2 c2 = new C1.c2();
  print(c2);
}