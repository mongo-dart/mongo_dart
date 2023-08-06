abstract class UnionType<T1, T2> {
  const UnionType(dynamic value)
      : valueOne = value is T1 ? value : null,
        valueTwo = value is T2 ? value : null;

  dynamic get value => valueOne ?? valueTwo;
  bool get isNull => value == null;

  final T1? valueOne;
  final T2? valueTwo;
}

abstract class MultiUnionType<T1, T2, T3, T4, T5> {
  const MultiUnionType(dynamic value)
      : valueOne = value is T1 ? value : null,
        valueTwo = value is T2 ? value : null,
        valueThree = value is T3 ? value : null,
        valueFour = value is T4 ? value : null,
        valueFive = value is T5 ? value : null;

  dynamic get value =>
      valueOne ?? valueTwo ?? valueThree ?? valueFour ?? valueFive;
  bool get isNull => value == null;

  final T1? valueOne;
  final T2? valueTwo;
  final T3? valueThree;
  final T4? valueFour;
  final T5? valueFive;
}
