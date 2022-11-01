import 'dart:async';
import 'dart:collection';

import 'package:universal_io/io.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart_old.dart' show ServerConfig;

import '../../error/connection_exception.dart';
import '../../error/mongo_dart_error.dart';
import '../../info/server_capabilities.dart';
import '../../message/deprecated/mongo_reply_message.dart';
import '../../../../src_old/database/info/server_status.dart';
import '../../message/handler/message_handler.dart';
import '../../message/mongo_modern_message.dart';
import '../../message/abstract/mongo_response_message.dart';
import '../../message/abstract/mongo_message.dart';
import '../connection_manager.dart';

const noSecureRequestError = 'The socket connection has been reset by peer.'
    '\nPossible causes:'
    '\n- Trying to connect to an ssl/tls encrypted database without specifiyng'
    '\n  either the query parm tls=true '
    'or the secure=true parameter in db.open()'
    '\n- The server requires a key certificate from the client, '
    'but no certificate has been sent'
    '\n- Others';

enum ConnectionStatus { closed, active, available }

abstract class ConnectionBase {
  final Logger log = Logger('Connection');
  Socket? socket;
  ConnectionStatus status = ConnectionStatus.closed;

  static bool _caCertificateAlreadyInHash = false;
  final ConnectionManager _manager;
  ServerConfig serverConfig;
  final Set _pendingQueries = <int>{};

  Map<int, Completer<MongoResponseMessage>> get _replyCompleters =>
      _manager.replyCompleters;

  Queue<MongoMessage> get _sendQueue => _manager.sendQueue;
  StreamSubscription<MongoResponseMessage>? _repliesSubscription;

  StreamSubscription<MongoResponseMessage>? get repliesSubscription =>
      _repliesSubscription;

  bool connected = false;
  bool _closed = false;
  bool get isClosed => _closed;
  final ServerCapabilities serverCapabilities = ServerCapabilities();
  final ServerStatus serverStatus = ServerStatus();

  ConnectionBase(this._manager, [ServerConfig? serverConfig])
      : serverConfig = serverConfig ?? ServerConfig();

  bool get isAuthenticated => serverConfig.isAuthenticated;

  Future connect() async {
    Socket locSocket;
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

        locSocket = await SecureSocket.connect(
            serverConfig.host, serverConfig.port, context: securityContext,
            onBadCertificate: (certificate) {
          // couldn't find here if the cause is an hostname mismatch
          return serverConfig.tlsAllowInvalidCertificates;
        });
      } else {
        locSocket = await Socket.connect(serverConfig.host, serverConfig.port);
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
    locSocket.done.catchError((error) {
      log.info('Socket error $error');
      throw ConnectionException('Socket error: $error');
    });
    socket = locSocket;

    _repliesSubscription = socket!
        .transform<MongoResponseMessage>(MessageHandler().transformer)
        .listen(receiveReply,
            onError: (e, st) async {
              log.severe('Socket error $e $st');
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
  }

  Future<void> close() async {
    _closed = true;
    connected = false;
    await socket?.close();
    return;
  }

  void sendBuffer() {
    log.fine(() => '_sendBuffer ${_sendQueue.isNotEmpty}');
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
      log.fine(() => 'Query $queryMessage');
      _sendQueue.addLast(queryMessage);
      sendBuffer();
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

  void executeDeprecated(MongoMessage mongoMessage, bool runImmediately) {
    if (_closed) {
      throw const ConnectionException(
          'Invalid state: Connection already closed.');
    }
    log.fine(() => 'Execute $mongoMessage');
    _sendQueue.addLast(mongoMessage);
    if (runImmediately) {
      sendBuffer();
    }
  }

  void receiveReply(MongoResponseMessage reply) {
    log.fine(() => reply.toString());
    var completer = _replyCompleters.remove(reply.responseTo);
    _pendingQueries.remove(reply.responseTo);
    if (completer != null) {
      log.fine(() => 'Completing $reply');
      completer.complete(reply);
    } else {
      if (!_closed) {
        log.info(() => 'Unexpected respondTo: ${reply.responseTo} $reply');
      }
    }
  }

  Future<MongoModernMessage> execute(MongoModernMessage modernMessage) async {
    if (status == ConnectionStatus.closed) {
      throw const ConnectionException(
          'Invalid state: Connection already closed.');
    } else if (status == ConnectionStatus.active) {
      throw const ConnectionException(
          'Invalid state: Connection already busy.');
    }
    log.fine(() => 'Message $modernMessage');
    _sendQueue.addLast(modernMessage);
    sendBuffer();

    MongoModernMessage? ret;
    await for (var reply in socket!
        .transform<MongoModernMessage>(MessageHandler().transformer)) {
      ret = reply;
      receiveReply(reply);
    }
    return ret ?? (throw MongoDartError('No Reply Received'));
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
  }
}
