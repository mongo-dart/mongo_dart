part of mongo_dart;

class _ServerCapabilities {
  int maxWireVersion = 0;
  bool aggregationCursor = false;
  bool writeCommands = false;
  bool authCommands = false;
  bool listCollections = false;
  bool listIndexes = false;
  int maxNumberOfDocsInBatch = 1000;
  bool supportsOpMsg = false;

  void getParamsFromIstMaster(Map<String, dynamic> isMaster) {
    if (isMaster.containsKey('maxWireVersion')) {
      maxWireVersion = isMaster['maxWireVersion'] as int;
    }
    if (maxWireVersion >= 1) {
      aggregationCursor = true;
      authCommands = true;
    }
    if (maxWireVersion >= 2) {
      writeCommands = true;
    }
    if (maxWireVersion >= 3) {
      listCollections = true;
      listIndexes = true;
    }
    if (maxWireVersion >= 6) {
      supportsOpMsg = true;
    }
  }
}

class _Connection {
  final Logger _log = Logger('Connection');
  final _ConnectionManager _manager;
  ServerConfig serverConfig;
  Socket socket;
  Set<int> _pendingQueries = {};

  Map<int, Completer<MongoResponseMessage>> get _replyCompleters =>
      _manager.replyCompleters;

  Queue<MongoMessage> get _sendQueue => _manager.sendQueue;
  StreamSubscription<MongoResponseMessage> _repliesSubscription;

  StreamSubscription<MongoResponseMessage> get repliesSubscription =>
      _repliesSubscription;

  bool connected = false;
  bool _closed = false;
  bool isMaster = false;
  final _ServerCapabilities serverCapabilities = _ServerCapabilities();
  final ServerStatus serverStatus = ServerStatus();

  _Connection(this._manager, [this.serverConfig]) {
    serverConfig ??= ServerConfig();
  }

  Future<bool> connect() async {
    Socket _socket;
    try {
      _socket = await Socket.connect(serverConfig.host, serverConfig.port);
    } catch (e, st) {
      _log.severe('Socket error on connect(): ${e} ${st}');
      _closed = true;
      connected = false;
      var ex = const ConnectionException('Could not connect to the Data Base.');
      throw ex;
    }

    // ignore: unawaited_futures
    _socket.done.catchError((error) => _log.info('Socket error ${error}'));
    socket = _socket;

    _repliesSubscription = socket
        .transform<MongoResponseMessage /*MongoReplyMessage*/ >(
            MongoMessageHandler().transformer)
        .listen(_receiveReply,
            onError: (e, st) {
              _log.severe('Socket error ${e} ${st}');
              if (!_closed) {
                _onSocketError();
              }
            },
            cancelOnError: true,
            onDone: () {
              if (!_closed) {
                _onSocketError();
              }
            });
    connected = true;
    return true;
  }

  Future close() {
    _closed = true;
    connected = false;
    return socket.close();
  }

  _sendBuffer() {
    _log.fine(() => '_sendBuffer ${_sendQueue.isNotEmpty}');
    var message = <int>[];
    while (_sendQueue.isNotEmpty) {
      var mongoMessage = _sendQueue.removeFirst();
      message.addAll(mongoMessage.serialize().byteList);
    }
    socket.add(message);
  }

  Future<MongoReplyMessage> query(MongoMessage queryMessage) {
    var completer = Completer<MongoReplyMessage>();
    if (!_closed) {
      _replyCompleters[queryMessage.requestId] = completer;
      _pendingQueries.add(queryMessage.requestId);
      _log.fine(() => 'Query $queryMessage');
      _sendQueue.addLast(queryMessage);
      _sendBuffer();
    } else {
      completer.completeError(const ConnectionException(
          'Invalid state: Connection already closed.'));
    }
    return completer.future;
  }

  ///   If runImmediately is set to false, the message is joined into one packet with
  ///   other messages that follows. This is used for joining insert, update and remove commands with
  ///   getLastError query (according to MongoDB docs, for some reason, these should
  ///   be sent 'together')

  void execute(MongoMessage mongoMessage, bool runImmediately) {
    if (_closed) {
      throw const ConnectionException(
          "Invalid state: Connection already closed.");
    }
    _log.fine(() => 'Execute $mongoMessage');
    _sendQueue.addLast(mongoMessage);
    if (runImmediately) {
      _sendBuffer();
    }
  }

  Future<MongoModernMessage> executeModernMessage(
      MongoModernMessage modernMessage) {
    Completer<MongoModernMessage> completer = Completer();
    if (!_closed) {
      _replyCompleters[modernMessage.requestId] = completer;
      _pendingQueries.add(modernMessage.requestId);
      _log.fine(() => 'Message $modernMessage');
      _sendQueue.addLast(modernMessage);
      _sendBuffer();
    } else {
      completer.completeError(const ConnectionException(
          "Invalid state: Connection already closed."));
    }
    return completer.future;
  }

  void _receiveReply(MongoResponseMessage reply) {
    _log.fine(() => reply.toString());
    Completer completer = _replyCompleters.remove(reply.responseTo);
    _pendingQueries.remove(reply.responseTo);
    if (completer != null) {
      _log.fine(() => 'Completing $reply');
      completer.complete(reply);
    } else {
      if (!_closed) {
        _log.info(() => "Unexpected respondTo: ${reply.responseTo} $reply");
      }
    }
  }

  void _onSocketError() {
    _closed = true;
    connected = false;
    var ex = const ConnectionException("connection closed.");
    _pendingQueries.forEach((id) {
      Completer completer = _replyCompleters.remove(id);
      completer.completeError(ex);
    });
    _pendingQueries.clear();
    if (isMaster) {
      _manager.close();
    }
  }
}

class ConnectionException implements Exception {
  final String message;

  const ConnectionException([String this.message = ""]);

  String toString() => "MongoDB ConnectionException: $message";
}
