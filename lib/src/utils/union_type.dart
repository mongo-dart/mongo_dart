abstract class UnionType<T1, T2> {
  const UnionType(dynamic value)
      : valueOne = value is T1 ? value : null,
        valueTwo = value is T2 ? value : null;

  dynamic get value => valueOne ?? valueTwo;

  final T1? valueOne;
  final T2? valueTwo;
}
