import 'package:mongo_dart/src/core/message/mongo_modern_message.dart'
    show MongoModernMessage;
import 'package:mongo_dart/src/utils/map_keys.dart'
    show keyReadPreference, keyWriteConcern;

import '../../core/error/mongo_dart_error.dart';
import '../../core/message/abstract/section.dart';
import '../../../src_old/database/commands/parameters/read_preference.dart'
    show ReadPreference;
import '../../core/network/abstract/connection_base.dart';
import '../../core/topology/server.dart';
import 'operation_base.dart' show Aspect, OperationBase;

/// Run a simple command
///
/// Designed for system commands where Db/Collection are not needed
class SimpleCommand extends OperationBase {
  Map<String, Object>? command;
  ReadPreference? readPreference;

  SimpleCommand(Map<String, Object> options,
      {this.command, Aspect? aspect, ConnectionBase? connection})
      : super(options, connection: connection, aspects: aspect);

  Map<String, Object> $buildCommand() => command == null
      ? throw MongoDartError('Command not specified')
      : command!;

  void processOptions(Map<String, Object?> command) {
    if (hasAspect(Aspect.writeOperation)) {
      applyWriteConcern(options, options: options);
      readPreference = ReadPreference.primary;
    } else {
      // Todo we have to manage Session
      options.remove(keyWriteConcern);
    }
    options.remove(keyReadPreference);

    options.removeWhere((key, value) => command.containsKey(key));
  }

  @override
  Future<Map<String, Object?>> execute(Server server,
      {ConnectionBase? connection}) async {
    var command = $buildCommand();

    processOptions(command);

    command.addAll(options);

    if (readPreference != null) {
      // search for the right connection
    }

    var modernMessage = MongoModernMessage(command);

    return server.executeModernMessage(modernMessage, connection: connection);
  }
}

/// Applies a write concern to a command based on well defined inheritance rules, optionally
/// detecting support for the write concern in the first place.
///
/// @param {Object} target the target command we will be applying the write concern to
/// @param {Object} sources sources where we can inherit default write concerns from
/// @param {Object} [options] optional settings passed into a command for write concern overrides
/// @returns {Object} the (now) decorated target
Map<String, Object> applyWriteConcern(Map<String, Object> target,
    {Map<String, Object>? options}) {
  options ??= <String, Object>{};

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
