part of mongo_dart;

class ChunkTransformer implements StreamTransformer<List<int>, List<int>> {
  
  int chunkSize; 

  StreamSubscription<List<int>> _subscription;
  StreamController<List<int>> _controller;
  List<int> _carry;

  ChunkTransformer([this.chunkSize = 1024 * 256]) {
    
  }
  
  Stream<List<int>> bind(Stream<List<int>> stream) {
    _controller = new StreamController<List<int>>(
        onPauseStateChange: _pauseChanged,
        onSubscriptionStateChange: _subscriptionChanged);

    void handle(List<int> data, bool isClosing) {
      if (_carry != null) {
        data.addAll(_carry);
        _carry = null;
      }
      int startPos = 0;
      int pos = 0;
      while (pos + chunkSize < data.length) {        
        _controller.add(data.getRange(pos,chunkSize));
        pos += chunkSize;
      }        
      if (data.length > pos) {
        _carry = data.getRange(pos, data.length - pos);  
        if (isClosing) {
          _controller.add(_carry);
        }
      }
    }
    _subscription = stream.listen(
        (data) => handle(data, false),
        onDone: () {
          // Handle remaining data (mainly _carry).
          handle([], true);
          _controller.close();
        },
        onError: _controller.signalError);
    return _controller.stream;
  }

  void _pauseChanged() {
    if (_controller.isPaused) {
      _subscription.pause();
    } else {
      _subscription.resume();
    }
  }

  void _subscriptionChanged() {
    if (!_controller.hasSubscribers) {
      _subscription.cancel();
    }
  }
}