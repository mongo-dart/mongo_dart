part of mongo_dart;

class CursorStream extends Stream<Map> {
  final Cursor cursor;
  Stream<Map> _source;
  StreamSubscription<Map> _subscription;
  StreamController<Map> _controller;

  CursorStream(Stream<Map> source, this.cursor) : _source = source {
    _controller = new StreamController<Map>(
        onListen: _onListen,
        onPause: _onPause,
        onResume: _onResume,
        onCancel: _onCancel);
  }

  StreamSubscription<Map> listen(void onData(Map line),
                                    {Function onError,
                                    void onDone(),
                                    bool cancelOnError }) {
    return _controller.stream.listen(onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError);
  }
  void _onError(error) {
    _controller.addError(error);
  }
  void _onListen() {
    _subscription = _source.listen(_onData,
    onError: _controller.addError,
    onDone: _onDone);
  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  void _onPause() {
    _subscription.pause();
  }

  void _onResume() {
    _subscription.resume();
  }

  void _onData(Map input) {
//    List<String> splits = input.split('\n');
//    splits[0] = _remainder + splits[0];
//    _remainder = splits.removeLast();
//    _lineCount += splits.length;
//    splits.forEach(_controller.add);
    _controller.add(input);
  }

  void _onDone() {
    _controller.close();
  }
  @deprecated
  ///
  Stream<Map> get stream => this;
}