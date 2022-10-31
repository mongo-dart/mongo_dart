part of mongo_dart;

class State {
  final String _value;
  const State._internal(this._value);
  @override
  String toString() => 'State.$_value';

  static const init = State._internal('INIT');
  static const opening = State._internal('OPENING');
  static const open = State._internal('OPEN');
  static const closing = State._internal('CLOSING');
  static const closed = State._internal('CLOSED');

  // For compatibility reasons

  @Deprecated('Use init instead')
  // ignore: constant_identifier_names
  static const INIT = init;

  @Deprecated('Use opening instead')
  // ignore: constant_identifier_names
  static const OPENING = opening;

  @Deprecated('Use open instead')
  // ignore: constant_identifier_names
  static const OPEN = open;

  @Deprecated('Use closing instead')
  // ignore: constant_identifier_names
  static const CLOSING = closing;

  @Deprecated('Use closed instead')
  // ignore: constant_identifier_names
  static const CLOSED = closed;
}
