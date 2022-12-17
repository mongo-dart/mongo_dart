import 'package:mongo_dart/src/core/message/mongo_modern_message.dart'
    show MongoModernMessage;
import 'package:mongo_dart/src/utils/map_keys.dart' show keyWriteConcern;

import '../../core/error/mongo_dart_error.dart';
import '../../database/document_types.dart';
import '../../topology/server.dart';
import 'operation_base.dart' show Aspect, Command, OperationBase, Options;

/// Run a command on a required server
///
/// Basic for all commands
class ServerCommand extends OperationBase {
  Command command;

  ServerCommand(this.command, Options options, {Aspect? aspect})
      : super(options, aspects: aspect);

  Command $buildCommand() => command;

  /// ReadPrefernce must be managed before
  void processOptions(Command command) {
    if (hasAspect(Aspect.writeOperation)) {
      applyWriteConcern(options, options: options);
    } else {
      // Todo we have to manage Session
      options.remove(keyWriteConcern);
    }

    options.removeWhere((key, value) => command.containsKey(key));
  }

  @override
  Future<Map<String, Object?>> execute() =>
      throw MongoDartError('Use executOnServer() instead');

  /// A session ID MUST NOT be used simultaneously by more than one operation.
  ///  Since drivers don't wait for a response for an unacknowledged write a
  /// driver would not know when the session ID could be reused.
  /// In theory a driver could use a new session ID for each unacknowledged
  /// write, but that would result in many orphaned sessions building
  /// up at the server.
  /// Therefore drivers MUST NOT send a session ID with unacknowledged
  /// writes under any circumstances:
  ///  For unacknowledged writes with an explicit session, drivers SHOULD
  /// raise an error. If a driver allows users to provide an explicit session
  /// with an unacknowledged write (e.g. for backwards compatibility),
  /// the driver MUST NOT send the session ID.
  /// For unacknowledged writes without an explicit session,
  /// drivers SHOULD NOT use an implicit session.
  /// If a driver creates an implicit session for unacknowledged writes
  /// without an explicit session, the driver MUST NOT send the session ID.
  ///Drivers MUST document the behavior of unacknowledged writes for both
  ///explicit and implicit sessions.
  @override
  Future<MongoDocument> executeOnServer(Server server) async {
    var command = $buildCommand();

    processOptions(command);

    command.addAll(options);

    var modernMessage = MongoModernMessage(command);

    return server.executeMessage(modernMessage);
  }
}

/// Applies a write concern to a command based on well defined inheritance rules, optionally
/// detecting support for the write concern in the first place.
///
/// @param {Object} target the target command we will be applying the write concern to
/// @param {Object} sources sources where we can inherit default write concerns from
/// @param {Object} [options] optional settings passed into a command for write concern overrides
/// @returns {Object} the (now) decorated target
Options applyWriteConcern(Options target, {Options? options}) {
  options ??= <String, dynamic>{};

  //Todo Session not yet implemented
  /*if (options[keySession] != null && options[keySession].inTransaction()) {
    // writeConcern is not allowed within a multi-statement transaction
    if (target.containsKey(keyWriteConcern)) {
      target.remove(keyWriteConcern);
    }
    return target;
  }*/

  if (target.containsKey(keyWriteConcern)) {
    if (target[keyWriteConcern] == null) {
      target.remove(keyWriteConcern);
    } else {
      return target;
    }
  }

  if (!identical(target, options) && options.containsKey(keyWriteConcern)) {
    if (options[keyWriteConcern] != null) {
      target[keyWriteConcern] = options[keyWriteConcern]!;
      return target;
    }
  }

  return target;
}
