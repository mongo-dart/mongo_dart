part of mongo_dart;

const noSecureRequestError = 'The socket connection has been reset by peer.'
    '\nPossible causes:'
    '\n- Trying to connect to an ssl/tls encrypted database without specifiyng'
    '\n  either the query parm tls=true '
    'or the secure=true parameter in db.open()'
    '\n- The server requires a key certificate from the client, '
    'but no certificate has been sent'
    '\n- Others';

class _ServerCapabilities {
  int minWireVersion = 0;
  int maxWireVersion = 0;
  bool aggregationCursor = false;
  bool writeCommands = false;
  bool authCommands = false;
  bool listCollections = false;
  bool listIndexes = false;
  int maxNumberOfDocsInBatch = 1000;
  bool supportsOpMsg = false;
  String? replicaSetName;
  List<String>? replicaSetHosts;
  bool get isReplicaSet => replicaSetName != null;
  int get replicaSetHostsNum => replicaSetHosts?.length ?? 0;
  bool get isSingleServerReplicaSet => isReplicaSet && replicaSetHostsNum == 1;
  bool isShardedCluster = false;
  bool isStandalone = false;
  String? fcv;

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
    if (isMaster.containsKey(keyMsg)) {
      isShardedCluster = true;
    } else if (isMaster.containsKey(keySetName)) {
      replicaSetName = isMaster[keySetName];
      replicaSetHosts = <String>[...isMaster[keyHosts]];
    } else {
      isStandalone = true;
    }
    if (maxWireVersion >= 13) {
      fcv = '5.0';
    } else if (isMaster.containsKey(keyTopologyVersion)) {
      fcv = '4.4';
    } else if (isMaster.containsKey(keyConnectionId)) {
      fcv = '4.2';
    } else if (maxWireVersion > 6) {
      // approximated
      fcv = '4.0';
    } else {
      fcv = '3.6';
    }
  }

  void getParamsFromHello(HelloResult result) {
    minWireVersion = result.minWireVersion;

    maxWireVersion = result.maxWireVersion;

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
    if (filled(result.msg)) {
      isShardedCluster = true;
    } else if (filled(result.setName)) {
      replicaSetName = result.setName;
      replicaSetHosts = <String>[...?result.hosts];
    } else {
      isStandalone = true;
    }

    if (maxWireVersion >= 13) {
      fcv = '5.0';
    } else if (maxWireVersion >= 9) {
      fcv = '4.4';
    } else if (maxWireVersion >= 8) {
      fcv = '4.2';
    } else if (maxWireVersion >= 7) {
      fcv = '4.0';
    } else {
      fcv = '3.6';
    }
  }
}

class Connection {
  static bool _caCertificateAlreadyInHash = false;
  final Logger _log = Logger('Connection');
  final _ConnectionManager _manager;
  ServerConfig serverConfig;
  Socket? socket;
  final Set _pendingQueries = <int>{};

  Map<int, Completer<MongoResponseMessage>> get _replyCompleters =>
      _manager.replyCompleters;

  Queue<MongoMessage> get _sendQueue => _manager.sendQueue;
  StreamSubscription<MongoResponseMessage>? _repliesSubscription;

  StreamSubscription<MongoResponseMessage>? get repliesSubscription =>
      _repliesSubscription;

  bool connected = false;
  bool _closed = false;
  bool isMaster = false;
  final _ServerCapabilities serverCapabilities = _ServerCapabilities();
  final ServerStatus serverStatus = ServerStatus();

  Connection(this._manager, [ServerConfig? serverConfig])
      : serverConfig = serverConfig ?? ServerConfig();

  bool get isAuthenticated => serverConfig.isAuthenticated;

  Future<bool> connect() async {
    Socket _socket;
    try {
      if (serverConfig.isSecure) {
        var securityContext = SecurityContext.defaultContext;
        if (serverConfig.tlsCAFileContent != null &&
            !_caCertificateAlreadyInHash) {
          securityContext
              .setTrustedCertificatesBytes(serverConfig.tlsCAFileContent!);
        }
        if (serverConfig.tlsCertificateKeyFileContent != null) {
          securityContext
            ..useCertificateChainBytes(
                serverConfig.tlsCertificateKeyFileContent!)
            ..usePrivateKeyBytes(serverConfig.tlsCertificateKeyFileContent!,
                password: serverConfig.tlsCertificateKeyFilePassword);
        }

        _socket = await SecureSocket.connect(
            serverConfig.host, serverConfig.port, context: securityContext,
            onBadCertificate: (certificate) {
          // couldn't find here if the cause is an hostname mismatch
          return serverConfig.tlsAllowInvalidCertificates;
        });
      } else {
        _socket = await Socket.connect(serverConfig.host, serverConfig.port);
      }
    } on TlsException catch (e) {
      if (e.osError?.message
              .contains('CERT_ALREADY_IN_HASH_TABLE(x509_lu.c:356)') ??
          false) {
        _caCertificateAlreadyInHash = true;
        return connect();
      }
      _closed = true;
      connected = false;
      var ex = ConnectionException(
          'Could not connect to ${serverConfig.hostUrl}\n- $e');
      throw ex;
    } catch (e) {
      _closed = true;
      connected = false;
      var ex = ConnectionException(
          'Could not connect to ${serverConfig.hostUrl}\n- $e');
      throw ex;
    }

    // ignore: unawaited_futures
    _socket.done.catchError((error) {
      _log.info('Socket error $error');
      throw ConnectionException('Socket error: $e');
    });
    socket = _socket;

    _repliesSubscription = socket!
        .transform<MongoResponseMessage>(MongoMessageHandler().transformer)
        .listen(_receiveReply,
            onError: (e, st) async {
              _log.severe('Socket error $e $st');
              if (!_closed) {
                await _closeSocketOnError(socketError: e);
              }
            },
            cancelOnError: true,
            // onDone is not called in any case after onData or OnError,
            // it is called when the socket closes, i.e. it is an error.
            // Possible causes:
            // * Trying to connect to a tls encrypted Database
            //   without specifing tls=true in the query parms or setting
            //   the secure parameter to true in db.open()
            onDone: () async {
              if (!_closed) {
                await _closeSocketOnError(socketError: noSecureRequestError);
              }
            });
    connected = true;
    return true;
  }

  Future<void> close() async {
    _closed = true;
    connected = false;
    await socket?.close();
    return;
  }

  void _sendBuffer() {
    _log.fine(() => '_sendBuffer ${_sendQueue.isNotEmpty}');
    var message = <int>[];
    while (_sendQueue.isNotEmpty) {
      var mongoMessage = _sendQueue.removeFirst();
      message.addAll(mongoMessage.serialize().byteList);
    }
    if (socket == null) {
      throw ConnectionException('The socket has not been created yet');
    }
    socket!.add(message);
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
          'Invalid state: Connection already closed.');
    }
    _log.fine(() => 'Execute $mongoMessage');
    _sendQueue.addLast(mongoMessage);
    if (runImmediately) {
      _sendBuffer();
    }
  }

  Future<MongoModernMessage> executeModernMessage(
      MongoModernMessage modernMessage) {
    var completer = Completer<MongoModernMessage>();
    if (!_closed) {
      _replyCompleters[modernMessage.requestId] = completer;
      _pendingQueries.add(modernMessage.requestId);
      _log.fine(() => 'Message $modernMessage');
      _sendQueue.addLast(modernMessage);
      _sendBuffer();
    } else {
      completer.completeError(const ConnectionException(
          'Invalid state: Connection already closed.'));
    }
    return completer.future;
  }

  void _receiveReply(MongoResponseMessage reply) {
    _log.fine(() => reply.toString());
    var completer = _replyCompleters.remove(reply.responseTo);
    _pendingQueries.remove(reply.responseTo);
    if (completer != null) {
      _log.fine(() => 'Completing $reply');
      completer.complete(reply);
    } else {
      if (!_closed) {
        _log.info(() => 'Unexpected respondTo: ${reply.responseTo} $reply');
      }
    }
  }

  Future<void> _closeSocketOnError({dynamic socketError}) async {
    _closed = true;
    connected = false;
    var ex = ConnectionException(
        'connection closed${socketError == null ? '.' : ': $socketError'}');
    for (var id in _pendingQueries) {
      var completer = _replyCompleters.remove(id);
      completer?.completeError(ex);
    }
    _pendingQueries.clear();
    if (isMaster) {
      await _manager.close();
    }
  }
}

class ConnectionException implements Exception {
  final String message;

  const ConnectionException([this.message = '']);

  @override
  String toString() => 'MongoDB ConnectionException: $message';
}
