import 'dart:async';
import 'package:meta/meta.dart';
import 'package:mongo_dart/src/core/network/abstract/connection_events.dart';
import 'package:mongo_dart/src/core/network/connection.dart';

import 'package:mongo_dart/src/core/network/secure_connection.dart';
import 'package:universal_io/io.dart';
import 'package:logging/logging.dart';

import '../../../utils/error.dart';
import '../../../utils/events.dart';
import '../../error/connection_exception.dart';
import '../../error/mongo_dart_error.dart';
import '../../info/server_config.dart';
import '../../message/handler/message_handler.dart';
import '../../message/mongo_modern_message.dart';

const noSecureRequestError = 'The socket connection has been reset by peer.'
    '\nPossible causes:'
    '\n- Trying to connect to an ssl/tls encrypted database without specifiyng'
    '\n  either the query parm tls=true '
    'or the secure=true parameter in db.open()'
    '\n- The server requires a key certificate from the client, '
    'but no certificate has been sent'
    '\n- Others';

enum ConnectionState { closed, active, available }

int _uniqueIdentifier = 0;

abstract class ConnectionBase with EventEmitter {
  @protected
  ConnectionBase.protected(this.serverConfig) : id = ++_uniqueIdentifier {
    // Todo find a more efficient way
    addLegalEvent<Connected>();
    addLegalEvent<ConnectionError>();
    addLegalEvent<ConnectionClosed>();
    addLegalEvent<ConnectionActive>();
    addLegalEvent<ConnectionAvailable>();
    addLegalEvent<ConnectionMessageReceived>();
  }

  factory ConnectionBase(ServerConfig serverConfig) {
    if (serverConfig.isSecure) {
      return SecureConnection(serverConfig);
    }
    return Connection(serverConfig);
  }

  ServerConfig serverConfig;

  late int id;
  final Logger log = Logger('Connection');
  Socket? socket;
  ConnectionState _state = ConnectionState.closed;

  bool get isClosed => _state == ConnectionState.closed;
  bool get isAvailable => _state == ConnectionState.available;
  bool get isActive => _state == ConnectionState.active;

  bool get isAuthenticated => serverConfig.isAuthenticated;
  Future<void> connect();

/* 
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

    /* socket!
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
            }); */
    //connected = true;
    _status = ConnectionStatus.available;
  }

 */

  Completer<MongoModernMessage>? completer;

  void setSocket(Socket newSocket) {
    socket = newSocket;
    _state = ConnectionState.available;
    emit(Connected(id));
    emit(ConnectionAvailable(id));

    socket!
        .transform<MongoModernMessage>(MessageHandler().transformer)
        .listen(receiveReply,
            onError: (e, st) async {
              log.severe('Socket error $e $st');
              if (!isClosed) {
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
              if (!isClosed) {
                await _closeSocketOnError(socketError: noSecureRequestError);
              }
            });
  }

  void receiveReply(MongoModernMessage reply) {
    log.fine(() => reply.toString());

    if (completer != null) {
      log.fine(() => 'Completing $reply');
      emit(ConnectionMessageReceived(id, reply));
      emit(ConnectionAvailable(id));
      completer!.complete(reply);
    } else {
      if (!isClosed) {
        log.info(() => 'Unexpected respondTo: ${reply.responseTo} $reply');
        emit(ConnectionError(id,
            MongoError('Unexpected respondTo: ${reply.responseTo} $reply')));
      }
    }
  }

  Future<void> close() async {
    await socket?.close();
    _state = ConnectionState.closed;
    emit(ConnectionClosed(id));
    return;
  }
/* 
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
  } */

  /*  void receiveReply(MongoResponseMessage reply) {
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
  } */

  Future<MongoModernMessage> execute_async(
      MongoModernMessage modernMessage) async {
    if (_state == ConnectionState.closed) {
      throw const ConnectionException(
          'Invalid state: Connection already closed.');
    } else if (_state == ConnectionState.active) {
      throw const ConnectionException(
          'Invalid state: Connection already busy.');
    }
    var message = <int>[];

    message.addAll(modernMessage.serialize().byteList);
    emit(ConnectionActive(id));

    log.finest(() => 'Submitting message $modernMessage');
    socket!.add(message);

    MongoModernMessage? ret;
    try {
      await for (var reply in socket!
          .transform<MongoModernMessage>(MessageHandler().transformer)) {
        ret = reply;
        emit(ConnectionMessageReceived(id, ret));
        break; //receiveReply(reply);
      }
    } catch (e, stack) {
      var error = MongoError('$e', stackTrace: stack);
      emit(ConnectionError(id, error));
      await _closeSocketOnError();
    }
    emit(ConnectionAvailable(id));

    if (ret == null) {
      throw MongoDartError('No Reply Received');
    }
    return ret;
  }

  Future<MongoModernMessage> execute(MongoModernMessage modernMessage) async {
    if (_state == ConnectionState.closed) {
      throw const ConnectionException(
          'Invalid state: Connection already closed.');
    } else if (_state == ConnectionState.active) {
      throw const ConnectionException(
          'Invalid state: Connection already busy.');
    }
    emit(ConnectionActive(id));

    var message = <int>[];
    message.addAll(modernMessage.serialize().byteList);
    emit(ConnectionActive(id));

    log.finest(() => 'Submitting message $modernMessage');
    completer = Completer<MongoModernMessage>();
    if (!isClosed) {
      socket!.add(message);
    } else {
      completer!.completeError(const ConnectionException(
          'Invalid state: Connection already closed.'));
    }
    return completer!.future;
  }

  Future<void> _closeSocketOnError({dynamic socketError}) async {
    _state = ConnectionState.closed;
    emit(ConnectionClosed(id));
    throw ConnectionException(
        'connection closed${socketError == null ? '.' : ': $socketError'}');
  }
}
