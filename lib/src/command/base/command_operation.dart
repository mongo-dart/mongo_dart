import 'package:mongo_dart/src/command/base/simple_command.dart';
import 'package:mongo_dart/src/utils/map_keys.dart'
    show key$Db, keyAuthdb, keyDbName, keyReadPreference, keyWriteConcern;

import '../../core/error/mongo_dart_error.dart';
import '../../topology/server.dart';
import '../parameters/read_preference.dart'
    show ReadPreference, resolveReadPreference;
import '../../database/base/mongo_database.dart';
import '../../database/base/mongo_collection.dart';
import 'operation_base.dart' show Aspect, Command, Options;

class CommandOperation extends SimpleCommand {
  CommandOperation(this.db, Command command, Options options,
      {this.collection, super.session, super.readPreference, super.aspect})
      : super(db.mongoClient, command, options: options);

  MongoDatabase db;
  MongoCollection? collection;

  /// This method is for exposing a common interface for the user
  /// Must be overriden from commands
  Future<dynamic> execute({Server? server}) {
    if (server == null) {
      return process();
    }
    return executeOnServer(server);
  }

  @override
  void processOptions(Command command) {
    // Get the db name we are executing against
    final dbName = (options[keyDbName] as String?) ??
        ((options[keyAuthdb] as String?) ?? db.databaseName);
    if (dbName == null) {
      throw MongoDartError('Database name not specified');
    }
    options.removeWhere((key, value) => key == keyDbName || key == keyAuthdb);
    //if (dbName != null) {
    command[key$Db] = dbName;
    //}
    if (hasAspect(Aspect.writeOperation)) {
      applyWriteConcern(options,
          options: options, db: db, collection: collection);
      readPreference = ReadPreference.primary;
    } else {
      options.remove(keyWriteConcern);
      // if Aspect is noInheritOptions, here a separated method is maintained
      // even if not necessary, waiting for the future check of the session
      // value.
      if (collection != null) {
        readPreference = resolveReadPreference(collection,
                options: options,
                inheritReadPreference: !hasAspect(Aspect.noInheritOptions)) ??
            ReadPreference.primary;
      } else {
        readPreference = resolveReadPreference(db,
                options: options,
                inheritReadPreference: !hasAspect(Aspect.noInheritOptions)) ??
            ReadPreference.primary;
      }
    }
    options.remove(keyReadPreference);

    options.removeWhere((key, value) => command.containsKey(key));

    if (db.mongoClient.serverApi != null) {
      command.addAll(db.mongoClient.serverApi!.options);
    }
  }
}

/// Applies a write concern to a command based on well defined inheritance rules, optionally
/// detecting support for the write concern in the first place.
///
/// @param {Object} target the target command we will be applying the write concern to
/// @param {Object} sources sources where we can inherit default write concerns from
/// @param {Object} [options] optional settings passed into a command for write concern overrides
/// @returns {Object} the (now) decorated target
Options applyWriteConcern(Options target,
    {Options? options, MongoDatabase? db, MongoCollection? collection}) {
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

  // Todo WriteConcern class not yet assigned to DbCollection
/*  if (collection != null && collection.writeConcern != null) {
    target[keyWriteConcern] = collection.writeConcern;
    return target;
  }*/

  if (db != null && db.writeConcern != null) {
    target[keyWriteConcern] = db.writeConcern!
        .asMap(db.mongoClient.topology!.getServer().serverStatus);
    return target;
  }

  return target;
}
