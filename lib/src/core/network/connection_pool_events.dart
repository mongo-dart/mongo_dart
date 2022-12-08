import '../../utils/generic_error.dart';
import '../../utils/events.dart';
import '../message/mongo_modern_message.dart';

Set<String> connectionPoolEvents = {
  extractType(PoolConnected),
  extractType(ConnectionPoolError),
  extractType(ConnectionPoolClosed),
  extractType(ConnectionPoolActive),
  extractType(ConnectionPoolAvailable)
};

abstract class ConnectionPoolEvent extends Event {}

/// This Message is sent when the ConnectionPool is connected
class PoolConnected extends ConnectionPoolEvent {}

/// This Message is sent when an Error is detected
class ConnectionPoolError extends ConnectionPoolEvent {
  ConnectionPoolError(this.error);

  GenericError error;
}

/// This Message is sent when the ConnectionPool is closed
class ConnectionPoolClosed extends ConnectionPoolEvent {}

/// This Message is sent when the connection is in use
class ConnectionPoolActive extends ConnectionPoolEvent {}

/// This Message is sent when the connection is available again after
/// beeign used
class ConnectionPoolAvailable extends ConnectionPoolEvent {}

/// This Message is sent when the ConnectionPool receive a response
class ConnectionPoolMessageReceived extends ConnectionPoolEvent {
  ConnectionPoolMessageReceived(this.reply);
  MongoModernMessage? reply;
}
