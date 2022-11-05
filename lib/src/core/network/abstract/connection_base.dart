import 'dart:async';
import 'package:meta/meta.dart';
import 'package:mongo_dart/src/core/network/connection.dart';

import 'package:mongo_dart/src/core/network/secure_connection.dart';
import 'package:universal_io/io.dart';
import 'package:logging/logging.dart';

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

abstract class ConnectionBase {
  @protected
  ConnectionBase.protected(this.id, this.serverConfig);

  factory ConnectionBase(int id, ServerConfig serverConfig) {
    if (serverConfig.isSecure) {
      return SecureConnection(id, serverConfig);
    }
    return Connection(id, serverConfig);
  }

  ServerConfig serverConfig;
  int id;
  final Logger log = Logger('Connection');
  Socket? socket;
  ConnectionState _state = ConnectionState.closed;

  bool get isClosed => _state == ConnectionState.closed;
  bool get isAvailable => _state == ConnectionState.available;

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
  void setSocket(Socket newSocket) {
    socket = newSocket;
    _state = ConnectionState.available;
  }

  Future<void> close() async {
    _state = ConnectionState.closed;
    await socket?.close();
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

  Future<MongoModernMessage> execute(MongoModernMessage modernMessage) async {
    if (_state == ConnectionState.closed) {
      throw const ConnectionException(
          'Invalid state: Connection already closed.');
    } else if (_state == ConnectionState.active) {
      throw const ConnectionException(
          'Invalid state: Connection already busy.');
    }
    log.fine(() => 'Message $modernMessage');
    var message = <int>[];

    message.addAll(modernMessage.serialize().byteList);
    socket!.add(message);

    MongoModernMessage? ret;
    await for (var reply in socket!
        .transform<MongoModernMessage>(MessageHandler().transformer)) {
      ret = reply;
      //receiveReply(reply);
    }
    return ret ?? (throw MongoDartError('No Reply Received'));
  }

  Future<void> _closeSocketOnError({dynamic socketError}) async {
    _state = ConnectionState.closed;
    throw ConnectionException(
        'connection closed${socketError == null ? '.' : ': $socketError'}');
  }
}
