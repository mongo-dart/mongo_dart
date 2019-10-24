part of mongo_dart;

class State {
  final _value;
  const State._internal(this._value);
  toString() => 'State.$_value';

  static const INIT = State._internal('INIT');
  static const OPENING = State._internal('OPENING');
  static const OPEN = State._internal('OPEN');
  static const CLOSING = State._internal('CLOSING');
  static const CLOSED = State._internal('CLOSED');
}
