import 'dart:async';

// **** Not used at present *****

mixin StreamSender {
  final StreamController _eventQueue = StreamController();
  Stream get eventQueue => _eventQueue.stream;

  void writeStream(Object event) {
    _eventQueue.add(event);
  }
}
