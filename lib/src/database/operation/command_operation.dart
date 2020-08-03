import 'package:mongo_dart/mongo_dart.dart' show Db, DbCollection;
import 'package:mongo_dart/src/database/message/mongo_modern_message.dart'
    show MongoModernMessage;
import 'package:mongo_dart/src/database/utils/map_keys.dart'
    show keyAuthdb, keyDbName, keyReadPreference, keyWriteConcern;

import 'parameters/read_preference.dart'
    show ReadPreference, resolveReadPreference;
import 'operation_base.dart' show Aspect, OperationBase;

class CommandOperation extends OperationBase {
  Db db;
  DbCollection collection;
  Map<String, Object> command;
  String namespace;

  CommandOperation(this.db, Map<String, Object> options,
      {this.collection, this.command, Aspect aspect})
      : super(options) {
    defineAspects(aspect);
    if (!hasAspect(Aspect.writeOperation)) {
      if (collection != null) {
        var readPreference = resolveReadPreference(collection, options);
        if (readPreference != null) {
          this.options[keyReadPreference] = readPreference.toJSON();
        }
      } else {
        var readPreference = resolveReadPreference(db, options);
        if (readPreference != null) {
          this.options[keyReadPreference] = readPreference.toJSON();
        }
      }
    } else {
      applyWriteConcern(this.options, this.options,
          db: db, collection: collection);
      this.options[keyReadPreference] = ReadPreference.primary.toJSON();
    }
  }

  Map<String, Object> $buildCommand() => command;

  @override
  Future<Map<String, Object>> execute() async {
    final db = this.db;
    final options = Map.from(this.options);

    // Todo implement topology
    // Did the user destroy the topology
    /*if (db?.serverConfig?.isDestroyed() ?? false) {
      return callback(MongoDartError('topology was destroyed'));
    }*/

    var command = $buildCommand();

    // Get the db name we are executing against
    final dbName = (options[keyDbName] as String) ??
        ((options[keyAuthdb] as String) ?? db.databaseName);

    // Convert the readPreference if its not a write
    if (hasAspect(Aspect.writeOperation)) {
      if (options[keyWriteConcern] != null
          // Todo we have to manage Session
          /*&& (options[keySession] == null ||
          !options[keySession].inTransaction())*/
          ) {
        command[keyWriteConcern] = options[keyWriteConcern];
      }
    }

    if (dbName != null) {
      command[r'$db'] = dbName;
    }

    var modernMessage = MongoModernMessage(command);
    return db.executeModernMessage(modernMessage /*, writeConcern*/);
  }
}

/// Applies a write concern to a command based on well defined inheritance rules, optionally
/// detecting support for the write concern in the first place.
///
/// @param {Object} target the target command we will be applying the write concern to
/// @param {Object} sources sources where we can inherit default write concerns from
/// @param {Object} [options] optional settings passed into a command for write concern overrides
/// @returns {Object} the (now) decorated target
Map<String, Object> applyWriteConcern(
    Map<String, Object> target, Map<String, Object> options,
    {Db db, DbCollection collection}) {
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
      target[keyWriteConcern] = options[keyWriteConcern];
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
        db.writeConcern.asMap(db.masterConnection.serverStatus);
    return target;
  }

  return target;
}
