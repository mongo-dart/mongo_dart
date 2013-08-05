library buffered_socket;

import 'dart:io';
import 'dart:async';
import 'package:logging/logging.dart';
import 'buffer.dart';


typedef ErrorHandler(AsyncError);
typedef DoneHandler();
typedef DataReadyHandler();

typedef Future<RawSocket> SocketFactory(host, int port);

class BufferedSocket {
  final Logger log;

  ErrorHandler onError;
  DoneHandler onDone;
  /**
   * When data arrives and there is no read currently in progress, the onDataReady handler is called.
   */
  DataReadyHandler onDataReady;

  RawSocket _socket;

  Buffer _writingBuffer;
  int _writeOffset;
  Completer<Buffer> _writeCompleter;

  Buffer _readingBuffer;
  int _readOffset;
  Completer<Buffer> _readCompleter;

  BufferedSocket._internal(this._socket, this.onDataReady, this.onDone, this.onError)
      : log = new Logger("BufferedSocket") {
    _socket.listen(_onData, onError: (error) {
      if (onError != null) {
        onError(error);
      }
    }, onDone: () {
      if (onDone != null) {
        onDone();
      }
    }, cancelOnError: true);
  }
  
  static Future<BufferedSocket> connect(String host, int port, {DataReadyHandler onDataReady,
      DoneHandler onDone, ErrorHandler onError, SocketFactory socketFactory}) {
    var c = new Completer<BufferedSocket>();
    var future;
    if (socketFactory != null) {
      future = socketFactory(host, port);
    } else {
      future = RawSocket.connect(host, port);
    }
    future.then((socket) => c.complete(new BufferedSocket._internal(socket, onDataReady, onDone, onError)),
        onError: onError);
    return c.future;
  }

  void _onData(RawSocketEvent event) {
    if (event == RawSocketEvent.READ) {
      log.finest("READ data");
      if (_readingBuffer == null) {
        log.finest("READ data: no buffer");
        if (onDataReady != null) {
          onDataReady();
        }
      } else {
        _readBuffer();
      }
    } else if (event == RawSocketEvent.READ_CLOSED) {
      log.fine('READ CLOSED');
    } else if (event == RawSocketEvent.WRITE) {
      log.fine("WRITE data");
      if (_writingBuffer != null) {
        _writeBuffer();
      }
    }
  }

  /**
   * Writes [buffer] to the socket, and returns the same buffer in a [Future] which
   * completes when it has all been written.
   */
  Future<Buffer> writeBuffer(Buffer buffer) {
    log.fine("writeBuffer length=${buffer.length}");
    if (_writingBuffer != null) {
      throw new StateError("Cannot write to socket, already writing");
    }
    _writingBuffer = buffer;
    _writeCompleter = new Completer<Buffer>();
    _writeOffset = 0;

    _writeBuffer();

    return _writeCompleter.future;
  }

  void _writeBuffer() {
    log.fine("_writeBuffer offset=${_writeOffset}");
    int bytesWritten = _writingBuffer.writeToSocket(_socket, _writeOffset, _writingBuffer.length - _writeOffset);
    log.fine("Wrote $bytesWritten bytes");
    _writeOffset += bytesWritten;
    if (_writeOffset == _writingBuffer.length) {
      _writeCompleter.complete(_writingBuffer);
      _writingBuffer = null;
    } else {
      _socket.writeEventsEnabled = true;
    }
  }

  /**
   * Reads into [buffer] from the socket, and returns the same buffer in a [Future] which
   * completes when enough bytes have been read to fill the buffer. 
   * This may not be called while there is still a read ongoing, but may be called before
   * onDataReady is called, in which case onDataReady will not be called when data arrives,
   * and the read will start instead.
   */
  Future<Buffer> readBuffer(Buffer buffer) {
    log.fine("readBuffer, length=${buffer.length}");
    if (_readingBuffer != null) {
      throw new StateError("Cannot read from socket, already reading");
    }
    _readingBuffer = buffer;
    _readOffset = 0;
    _readCompleter = new Completer<Buffer>();

    if (_socket.available() > 0) {
      log.fine("readBuffer, data already ready");
      _readBuffer();
    } else {
      log.fine("readBuffer, data NOT ready");
    }
    

    return _readCompleter.future;
  }

  void _readBuffer() {
    int bytesRead = _readingBuffer.readFromSocket(_socket, _readingBuffer.length - _readOffset);
    log.fine("read $bytesRead bytes");
    _readOffset += bytesRead;
    if (_readOffset == _readingBuffer.length) {
      _readCompleter.complete(_readingBuffer);
      _readingBuffer = null;
    }
  }

  void close() {
    _socket.close();
  }
  bool get readyToWrite => _writingBuffer == null;
}
