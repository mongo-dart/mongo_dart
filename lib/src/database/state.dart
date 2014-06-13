part of mongo_dart;
class State {
  final _value;
  const State._internal(this._value);
  toString() => 'Enum.$_value';

  static const INIT = const State._internal(0);
  static const OPEN = const State._internal(1);
  static const CLOSED = const State._internal(2);
}