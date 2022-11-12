import 'package:mongo_dart/mongo_dart_old.dart' show Db, DbCollection, State;
import 'package:mongo_dart/src/core/message/mongo_modern_message.dart'
    show MongoModernMessage;
import 'package:mongo_dart/src/utils/map_keys.dart'
    show
        keyAuthdb,
        keyDatabaseName,
        keyDbName,
        keyReadPreference,
        keyWriteConcern;

import '../../core/error/mongo_dart_error.dart';
import '../../core/network/deprecated/connection_multi_request.dart';
import '../../../src_old/database/commands/parameters/read_preference.dart'
    show ReadPreference, resolveReadPreference;
import 'operation_base.dart' show Aspect, OperationBase;

/// Run a simple command
///
/// Designed for system commands where Db/Collection are not needed
class SimpleCommand extends OperationBase {
  Map<String, Object>? command;
  ReadPreference? readPreference;

  SimpleCommand(Map<String, Object> options,
      {this.command, Aspect? aspect, ConnectionMultiRequest? connection})
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
  Future<Map<String, Object?>> execute({bool skipStateCheck = false}) async {
    var command = $buildCommand();

    processOptions(command);

    command.addAll(options);

    if (readPreference != null) {
      // search for the right connection
    }

    var modernMessage = MongoModernMessage(command);

    return db.executeModernMessage(modernMessage,
        connection: connection, skipStateCheck: skipStateCheck);
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
    {Map<String, Object>? options, Db? db, DbCollection? collection}) {
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

  // Todo WriteConcern class not yet assigned to DbCollection
/*  if (collection != null && collection.writeConcern != null) {
    target[keyWriteConcern] = collection.writeConcern;
    return target;
  }*/

  if (db != null && db.writeConcern != null) {
    target[keyWriteConcern] =
        db.writeConcern!.asMap(db.masterConnection.serverStatus);
    return target;
  }

  return target;
}
