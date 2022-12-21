import 'package:mongo_dart/src/commands/base/simple_command.dart';
import 'package:mongo_dart/src/utils/map_keys.dart'
    show
        keyAuthdb,
        keyDatabaseName,
        keyDbName,
        keyReadPreference,
        keyWriteConcern;

import '../../core/error/mongo_dart_error.dart';
import '../parameters/read_preference.dart'
    show ReadPreference, resolveReadPreference;
import '../../database/mongo_database.dart';
import '../../database/mongo_collection.dart';
import 'operation_base.dart' show Aspect, Options;

class CommandOperation extends SimpleCommand {
  CommandOperation(
      this.db, Map<String, Object> command, Map<String, Object> options,
      {this.collection, ReadPreference? readPreference, Aspect? aspect})
      : super(
            db.mongoClient.topology ??
                (throw MongoDartError(
                    'Topology is required executing a command')),
            command,
            options,
            aspect: aspect,
            readPreference: readPreference) {
    //aspect ??= Aspect.noInheritOptions;
    //defineAspects(aspect);
  }

  MongoDatabase db;
  MongoCollection? collection;

  @override
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
      // TODO we have to manage Session
      options.remove(keyWriteConcern);
      // if Aspect is noInheritOptions, here a separated method is maintained
      // even if not necessary, waiting for the future check of the session
      // value.
      if (collection != null) {
        readPreference = resolveReadPreference(collection, options,
                inheritReadPreference: !hasAspect(Aspect.noInheritOptions)) ??
            ReadPreference.primary;
      } else {
        readPreference = resolveReadPreference(db, options,
                inheritReadPreference: !hasAspect(Aspect.noInheritOptions)) ??
            ReadPreference.primary;
      }
    }
    options.remove(keyReadPreference);

    options.removeWhere((key, value) => command.containsKey(key));
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
    target[keyWriteConcern] = db.writeConcern!
        .asMap(db.mongoClient.topology!.getServer().serverStatus);
    return target;
  }

  return target;
}
