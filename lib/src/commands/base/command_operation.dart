import 'package:mongo_dart/mongo_dart_old.dart' show State;
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
import '../../core/network/abstract/connection_base.dart';
import '../parameters/read_preference.dart'
    show ReadPreference, resolveReadPreference;
import '../../database/db.dart';
import '../../database/dbcollection.dart';
import '../../topology/server.dart';
import 'operation_base.dart' show Aspect, OperationBase;

class CommandOperation extends OperationBase {
  late Db db;
  DbCollection? collection;
  Map<String, Object>? command;
  //String namespace;
  ReadPreference? readPreference;

  CommandOperation(Db? db, Map<String, Object> options,
      {this.collection,
      this.command,
      Aspect? aspect,
      ConnectionBase? connection})
      : super(options, connection: connection, aspects: aspect) {
    db ??= collection?.db;
    //aspect ??= Aspect.noInheritOptions;
    //defineAspects(aspect);
    if (db == null) {
      throw MongoDartError('Database reference required for this command');
    }
    // ignore: prefer_initializing_formals
    this.db = db;
  }

  Map<String, Object> $buildCommand() => command == null
      ? throw MongoDartError('Command not specified')
      : command!;

  void processOptions(Map<String, Object?> command) {
    // Get the db name we are executing against
    final dbName = (options[keyDbName] as String?) ??
        ((options[keyAuthdb] as String?) ?? db.databaseName);
    if (dbName == null) {
      throw MongoDartError('Database name not specified');
    }
    options.removeWhere((key, value) => key == keyDbName || key == keyAuthdb);
    //if (dbName != null) {
    command[keyDatabaseName] = dbName;
    //}
    if (hasAspect(Aspect.writeOperation)) {
      applyWriteConcern(options,
          options: options, db: db, collection: collection);
      readPreference = ReadPreference.primary;
    } else {
      // Todo we have to manage Session
      options.remove(keyWriteConcern);
      // if Aspect is noInheritOptions, here a separated method is maintained
      // even if not necessary, waiting for the future check of the session
      // value.
      if (collection != null) {
        readPreference = resolveReadPreference(collection, options,
            inheritReadPreference: !hasAspect(Aspect.noInheritOptions));
      } else {
        readPreference = resolveReadPreference(db, options,
            inheritReadPreference: !hasAspect(Aspect.noInheritOptions));
      }
    }
    options.remove(keyReadPreference);

    options.removeWhere((key, value) => command.containsKey(key));
  }

  @override
  Future<Map<String, Object?>> execute(Server server,
      {ConnectionBase? connection}) async {
    final db = this.db;
    if (db.state != State.open) {
      throw MongoDartError('Db is in the wrong state: ${db.state}');
    }
    //final options = Map.from(this.options);

    // Todo implement topology
    // Did the user destroy the topology
    /*if (db?.serverConfig?.isDestroyed() ?? false) {
      return callback(MongoDartError('topology was destroyed'));
    }*/

    var command = $buildCommand();

    processOptions(command);

    command.addAll(options);

    if (readPreference != null) {
      // search for the right connection
    }

    // Todo remove debug()
    //print(command);
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
    target[keyWriteConcern] = db.writeConcern!.asMap(db.mongoClient.topology!
        .getServer(ReadPreference.primary)
        .serverStatus);
    return target;
  }

  return target;
}
