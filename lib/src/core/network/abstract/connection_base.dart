import 'dart:async';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/core/network/abstract/connection_events.dart';
import 'package:mongo_dart/src/core/network/connection.dart';

import 'package:mongo_dart/src/core/network/secure_connection.dart';
import 'package:mongo_dart/src/utils/generic_error.dart';
import 'package:universal_io/io.dart';
import 'package:logging/logging.dart';

import '../../../utils/events.dart';
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

Set<String> _legalEvents = <String>{
  extractType(Connected),
  extractType(ConnectionError),
  extractType(ConnectionActive),
  extractType(ConnectionClosed),
  extractType(ConnectionAvailable),
  extractType(ConnectionMessageReceived)
};

abstract class ConnectionBase with EventEmitter {
  @protected
  ConnectionBase.protected(this.serverConfig) : id = ++_uniqueIdentifier {
    legalEvents = _legalEvents;
  }

  factory ConnectionBase(ServerConfig serverConfig) {
    if (serverConfig.isSecure) {
      return SecureConnection(serverConfig);
    }
    return Connection(serverConfig);
  }

  late int id;
  ServerConfig serverConfig;

  @protected
  final Logger log = Logger('Connection');

  Socket? socket;
  ConnectionState _state = ConnectionState.closed;
  Completer<MongoModernMessage>? _completer;

  bool get isClosed => _state == ConnectionState.closed;
  bool get isAvailable => _state == ConnectionState.available;
  bool get isActive => _state == ConnectionState.active;

  bool get isAuthenticated => serverConfig.isAuthenticated;

  Future<void> connect() async {
    if (!isClosed) {
      await _closeOnError(MongoDartError(
          'Call to connect(), but the connection is alreay open'));
    }
    return internalConnect();
  }

  Future<void> _closeOnError(GenericError error) async {
    await _closeConnection();
    await emit(ConnectionError(id, error));
    log.severe(error.originalErrorMessage);
    _completer == null ? throw error : _completer!.completeError(error);
  }

  Future<void> _closeConnection() async {
    if (!isClosed) {
      await emit(ConnectionClosed(id));
      _state = ConnectionState.closed;
    }
    if (socket != null) {
      await socket!.flush();
      await socket!.close();
      socket = null;
    }
  }

  @protected
  Future<void> internalConnect();

  void setSocket(Socket newSocket) {
    socket = newSocket;

    socket!
        .transform<MongoModernMessage>(MessageHandler().transformer)
        .listen(receiveReply, onError: (error, st) async {
      await _closeOnError(
          MongoDartError('Socket error $error', stackTrace: st));
    },
            //cancelOnError: true,
            // onDone is not called in any case after onData or OnError,
            // it is called when the socket closes, i.e. it is an error.
            // Possible causes:
            // * Trying to connect to a tls encrypted Database
            //   without specifing tls=true in the query parms or setting
            //   the secure parameter to true in db.open()
            onDone: () async {
      await _closeOnError(MongoDartError(noSecureRequestError));
    });
    // ignore: unawaited_futures
    socket!.done.catchError((error) async {
      await _closeOnError(MongoDartError('Socket error $error'));
    });
    emit(Connected(id));
    _state = ConnectionState.available;
    emit(ConnectionAvailable(id));
  }

  Future<MongoModernMessage> execute(MongoModernMessage modernMessage) async {
    if (_state == ConnectionState.closed) {
      await _closeOnError(
          MongoDartError('Invalid state: Connection already closed.'));
    } else if (_state == ConnectionState.active) {
      await _closeOnError(
          MongoDartError('Invalid state: Connection already processing.'));
    }
    await emit(ConnectionActive(id));

    var message = <int>[];
    message.addAll(modernMessage.serialize().byteList);

    log.finest(() => 'Submitting message $modernMessage');
    _completer = Completer<MongoModernMessage>();

    socket!.add(message);

    return _completer!.future;
  }

  Future<void> receiveReply(MongoModernMessage reply) async {
    log.finest(() => reply.toString());

    if (_completer != null) {
      log.fine(() => 'Completing $reply');
      await emit(ConnectionMessageReceived(id, reply));
      await emit(ConnectionAvailable(id));
      _completer!.complete(reply);
    } else {
      await _closeOnError(
          MongoDartError('Unexpected respondTo: ${reply.responseTo} $reply'));
    }
  }

  Future<void> close() async => _closeConnection();
}
