part of mongo_dart;

class State {
  final _value;
  const State._internal(this._value);
  toString() => 'State.$_value';

  static const INIT = const State._internal('INIT');
  static const OPENING = const State._internal('OPENING');
  static const OPEN = const State._internal('OPEN');
  static const CLOSING = const State._internal('CLOSING');
  static const CLOSED = const State._internal('CLOSED');
}
