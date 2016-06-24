part of mongo_dart;

class _ServerCapabilities {
  int maxWireVersion = 0;
  bool aggregationCursor = false;
  bool writeCommands = false;
  bool authCommands = false;
  bool listCollections = false;
  bool listIndexes = false;
  int maxNumberOfDocsInBatch = 1000;

  getParamsFromIstMaster(Map isMaster) {
    if (isMaster.containsKey('maxWireVersion')) {
      maxWireVersion = isMaster['maxWireVersion'];
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
  }
}

class _Connection {
  final Logger _log = new Logger('Connection');
  _ConnectionManager _manager;
  ServerConfig serverConfig;
  Socket socket;
  Set<int> _pendingQueries = new Set();
  get _replyCompleters => _manager.replyCompleters;
  get _sendQueue => _manager.sendQueue;
  StreamSubscription<MongoReplyMessage> _repliesSubscription;
  StreamSubscription<MongoReplyMessage> get repliesSubscription =>
      _repliesSubscription;

  bool connected = false;
  bool _closed = false;
  bool isMaster = false;
  final _ServerCapabilities serverCapabilities = new _ServerCapabilities();

  _Connection(this._manager, [this.serverConfig]) {
    if (serverConfig == null) {
      serverConfig = new ServerConfig();
    }
  }

  Future<bool> connect() {
    Completer completer = new Completer();
    Socket.connect(serverConfig.host, serverConfig.port).then((Socket _socket) {
      // Socket connected.
      socket = _socket;
      _repliesSubscription = socket
          .transform(new MongoMessageHandler().transformer)
          .listen(_receiveReply, onError: (e) {
        _log.severe("Socket error ${e}");
        //completer.completeError(e);
      }, onDone: () {
        if (!_closed) {
          _onSocketError();
        }
      });
      connected = true;
      completer.complete(true);
    }).catchError((err) {
      completer.completeError(err);
    });
    return completer.future;
  }

  Future close() {
    _closed = true;
    return socket.close();
  }

  _sendBuffer() {
    _log.fine(() => '_sendBuffer ${!_sendQueue.isEmpty}');
    List<int> message = [];
    while (!_sendQueue.isEmpty) {
      var mongoMessage = _sendQueue.removeFirst();
      message.addAll(mongoMessage.serialize().byteList);
    }
    socket.add(message);
  }

  Future<MongoReplyMessage> query(MongoMessage queryMessage) {
    Completer completer = new Completer();
    if (!_closed) {
      _replyCompleters[queryMessage.requestId] = completer;
      _pendingQueries.add(queryMessage.requestId);
      _log.fine(() => 'Query $queryMessage');
      _sendQueue.addLast(queryMessage);
      _sendBuffer();
    } else {
      completer.completeError(const ConnectionException(
          "Invalid state: Connection already closed."));
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

  void _receiveReply(MongoReplyMessage reply) {
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
    var ex = const ConnectionException("connection closed.");
    _pendingQueries.forEach((id) {
      Completer completer = _replyCompleters.remove(id);
      completer.completeError(ex);
    });
    _pendingQueries.clear();
  }
}

class ConnectionException implements Exception {
  final String message;

  const ConnectionException([String this.message = ""]);

  String toString() => "MongoDB ConnectionException: $message";
}
