//part of mongo_dart;

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/command/base/operation_base.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';
import 'package:sasl_scram/sasl_scram.dart' show UsernamePasswordCredential;

import '../../core/auth/auth.dart';
import '../../../src_old/auth/mongodb_cr_authenticator.dart';
import '../../core/auth/scram_sha1_authenticator.dart';
import '../../core/auth/scram_sha256_authenticator.dart';
import '../../topology/abstract/topology.dart';
import '../modern_cursor.dart';
import '../../command/base/command_operation.dart';
import '../../core/message/abstract/mongo_message.dart';
import '../../core/message/deprecated/mongo_reply_message.dart';
import '../../core/network/abstract/connection_base.dart';
import '../../topology/server.dart';

class MongoDatabase {
  @protected
  MongoDatabase.protected(this.mongoClient, this.databaseName);

  factory MongoDatabase(MongoClient mongoClient, String databaseName) {
    if (mongoClient.serverApi != null) {
      switch (mongoClient.serverApi!.version) {
        case ServerApiVersion.v1:
          return MongoDatabaseV1(mongoClient, databaseName);
        default:
          throw MongoDartError(
              'Stable Api ${mongoClient.serverApi!.version} not managed');
      }
    }
    return MongoDatabaseOpen(mongoClient, databaseName);
  }

  final log = Logger('Db');
  final List<String> _uriList = <String>[];
  late MongoClient mongoClient;

  //State state = State.init;
  String? databaseName;
  String? _debugInfo;
  MongoDatabase? authSourceDb;

  AuthenticationScheme? authenticationScheme;
  WriteConcern? _writeConcern;
  ReadConcern? _readConcern;
  ReadPreference? readPreference;

  //Todo temp solution
  Server get server => topology.getServer();
  Topology get topology =>
      mongoClient.topology ??
      (throw MongoDartError('Topology not yet assigned'));

  @override
  String toString() => 'Db($databaseName,$_debugInfo)';

  /// Sets the readPreference at Database level
  void setReadPref(ReadPreference? readPreference) =>
      this.readPreference = readPreference;

  /// Runs a database command
  Future<MongoDocument> runCommand(Command command) =>
      CommandOperation(this, command, <String, dynamic>{}).execute();

  /// Creates a collection object
  MongoCollection collection(String collectionName) =>
      MongoCollection(this, collectionName);

  /// At present it can be defined only at client level
  ServerApi? get serverApi => mongoClient.serverApi;

  WriteConcern? get writeConcern => _writeConcern ?? mongoClient.writeConcern;
  ReadConcern? get readConcern => _readConcern ?? mongoClient.readConcern;

  // ********************************************************************
  // ********************          OLD          *************************
  // ********************************************************************

  MongoDatabase getSibling(String dbName) => mongoClient.db(dbName: dbName);

  List<String> get uriList => _uriList.toList();

  void selectAuthenticationMechanism(String authenticationSchemeName) {
    if (authenticationSchemeName == ScramSha1Authenticator.name) {
      authenticationScheme = AuthenticationScheme.SCRAM_SHA_1;
    } else if (authenticationSchemeName == ScramSha256Authenticator.name) {
      authenticationScheme = AuthenticationScheme.SCRAM_SHA_256;
    } else if (authenticationSchemeName == MongoDbCRAuthenticator.name) {
      authenticationScheme = AuthenticationScheme.MONGODB_CR;
    } else {
      throw MongoDartError('Provided authentication scheme is '
          'not supported : $authenticationSchemeName');
    }
  }

  Future<MongoReplyMessage> queryMessage(MongoMessage queryMessage,
      {ConnectionBase? connection}) {
    throw MongoDartError('No More used');
  }

  void executeMessage(MongoMessage message, WriteConcern? writeConcern,
      {ConnectionBase? connection}) {
    throw MongoDartError('No More used');
  }

  @Deprecated('Do Not USe')
  Future open(Server server,
      {ConnectionBase? connection,
      WriteConcern writeConcern = WriteConcern.acknowledged,
      bool secure = false,
      bool tlsAllowInvalidCertificates = false,
      String? tlsCAFile,
      String? tlsCertificateKeyFile,
      String? tlsCertificateKeyFilePassword}) async {
    throw MongoDartError('No More Used');
  }

  Future<Map<String, dynamic>> executeDbCommand(MongoMessage message,
      {ConnectionBase? connection}) async {
    throw MongoDartError('No More used');
  }

  bool documentIsNotAnError(firstRepliedDocument) =>
      firstRepliedDocument['ok'] == 1.0 && firstRepliedDocument['err'] == null;

  Future<bool> dropCollection(String collectionName) async {
    var result = await modernDrop(collectionName);
    return result[keyOk] == 1.0;
  }

  ///   Drop current database
  Future drop() async {
    var result = await modernDropDatabase();
    return result[keyOk] == 1.0;
  }

  Future<Map<String, dynamic>> removeFromCollection(String collectionName,
      [Map<String, dynamic> selector = const {},
      WriteConcern? writeConcern]) async {
    var collection = this.collection(collectionName);
    var result = await collection.deleteMany(
      selector,
      writeConcern: writeConcern,
    );
    return result.serverResponses.first;
  }

  @Deprecated('No More Used')
  Future<Map<String, dynamic>> getLastError(Server server,
      {ConnectionBase? connection, WriteConcern? writeConcern}) async {
    writeConcern ??= _writeConcern;
    return GetLastErrorCommand(this, writeConcern: writeConcern).execute();
  }

  @Deprecated('Deprecated since version 4.0.')
  Future<Map<String, dynamic>> getNonce({ConnectionBase? connection}) {
    throw MongoDartError('getnonce command not managed in this version');
  }

  // Todo new version needed?
  @Deprecated('No More Used')
  Future<Map<String, dynamic>> getBuildInfo({ConnectionBase? connection}) {
    throw MongoDartError('No More used');
  }

  Future<Map<String, dynamic>> wait() => throw MongoDartError('No More used');

  // Todo new version ?
  /// Analogue to shell's `show dbs`. Helper for `listDatabases` mongodb command.
  ///   @Deprecated('No More Used')
  Future<List> listDatabases() async {
    throw MongoDartError('No More used');
  }

  /// Analogue to shell's `show collections`
  /// This method uses system collections and therefore do not work on MongoDB v3.0 with and upward
  /// with WiredTiger
  /// Use `getCollectionNames` instead
  @Deprecated('Use `getCollectionNames` instead')
  Future<List<String?>> listCollections() async {
    var ret = await modernListCollections().toList();

    return [
      for (var element in ret)
        for (var nameKey in element.keys)
          if (nameKey == keyName) element[keyName]
    ];
  }

  Future<List<Map<String, dynamic>>> getCollectionInfos(
      [Map<String, dynamic> filter = const {}]) async {
    return modernListCollections(filter: filter).toList();
  }

  Future<List<String?>> getCollectionNames(
      [Map<String, dynamic> filter = const {}]) async {
    var ret = await modernListCollections().toList();

    return [
      for (var element in ret)
        for (var nameKey in element.keys)
          if (nameKey == keyName) element[keyName]
    ];
  }

  Future<bool> authenticate(String userName, String password, Server server,
      {ConnectionBase? connection}) async {
    var credential = UsernamePasswordCredential()
      ..username = userName
      ..password = password;

    server.serverConfig.userName ??= userName;
    server.serverConfig.password ??= password;

    if (authenticationScheme == null) {
      throw MongoDartError('Authentication scheme not specified');
    }
    var authenticator =
        Authenticator.create(authenticationScheme!, this, credential);

    await authenticator.authenticate(server, connection: connection);

    server.serverConfig.isAuthenticated = true;
    return true;
  }

  String _createIndexName(Map<String, dynamic> keys) {
    var name = '';

    keys.forEach((key, value) {
      if (name.isEmpty) {
        name = '${key}_$value';
      } else {
        name = '${name}_${key}_$value';
      }
    });

    return name;
  }

  Future<Map<String, dynamic>> createIndex(String collectionName,
      {String? key,
      Map<String, dynamic>? keys,
      bool? unique,
      bool? sparse,
      bool? background,
      bool? dropDups,
      Map<String, dynamic>? partialFilterExpression,
      String? name}) {
    return collection(collectionName).createIndex(
        key: key,
        keys: keys,
        unique: unique,
        sparse: sparse,
        background: background,
        dropDups: dropDups,
        partialFilterExpression: partialFilterExpression,
        name: name);
  }

  Map<String, dynamic> _setKeys(String? key, Map<String, dynamic>? keys) {
    if (key != null && keys != null) {
      throw ArgumentError('Only one parameter must be set: key or keys');
    }

    if (key != null) {
      keys = {};
      keys[key] = 1;
    }

    if (keys == null) {
      throw ArgumentError('key or keys parameter must be set');
    }

    return keys;
  }

  Future ensureIndex(String collectionName,
      {String? key,
      Map<String, dynamic>? keys,
      bool? unique,
      bool? sparse,
      bool? background,
      bool? dropDups,
      Map<String, dynamic>? partialFilterExpression,
      String? name}) async {
    keys = _setKeys(key, keys);
    var indexInfos = await collection(collectionName).getIndexes();

    name ??= _createIndexName(keys);

    if (indexInfos.any((info) => info['name'] == name) ||
        // For compatibility reasons, old indexes where created with
        // a leading underscore
        indexInfos.any((info) => info['name'] == '_$name')) {
      return {'ok': 1.0, 'result': 'index preexists'};
    }

    var createdIndex = await createIndex(collectionName,
        keys: keys,
        unique: unique,
        sparse: sparse,
        background: background,
        dropDups: dropDups,
        partialFilterExpression: partialFilterExpression,
        name: name);

    return createdIndex;
  }

  // **********************************************************+
  // ************** OP_MSG_COMMANDS ****************************
  // ***********************************************************

  /// This method drops the current DB
  Future<Map<String, Object?>> modernDropDatabase(
      {DropDatabaseOptions? dropOptions,
      Map<String, Object>? rawOptions}) async {
    var command = DropDatabaseCommand(this,
        dropDatabaseOptions: dropOptions, rawOptions: rawOptions);
    return command.execute();
  }

  /// This method return the status information on the
  /// connection.
  ///
  /// Only works from version 3.6
  Future<Map<String, Object?>> serverStatus(
      {Map<String, Object>? options}) async {
    var operation = ServerStatusCommand(this,
        serverStatusOptions: ServerStatusOptions.instance);
    return operation.executeOnServer(server);
  }

  /// This method explicitly creates a collection
  Future<Map<String, Object?>> createCollection(String name,
      {CreateCollectionOptions? createCollectionOptions,
      Map<String, Object>? rawOptions}) async {
    var command = CreateCollectionCommand(this, name,
        createCollectionOptions: createCollectionOptions,
        rawOptions: rawOptions);
    return command.execute();
  }

  /// This method retuns a cursor to get a list of the collections
  /// for this DB.
  ///
  Stream<Map<String, dynamic>> modernListCollections(
      {SelectorBuilder? selector,
      Map<String, Object?>? filter,
      ListCollectionsOptions? findOptions,
      Map<String, Object>? rawOptions}) {
    var command = ListCollectionsCommand(this,
        filter:
            filter ?? (selector?.map == null ? null : selector!.map[key$Query]),
        listCollectionsOptions: findOptions,
        rawOptions: rawOptions);

    return ModernCursor(command, server).stream;
  }

  /// This method creates a view
  Future<Map<String, Object?>> createView(
      String view, String source, List pipeline,
      {CreateViewOptions? createViewOptions,
      Map<String, Object>? rawOptions}) async {
    var command = CreateViewCommand(this, view, source, pipeline,
        createViewOptions: createViewOptions, rawOptions: rawOptions);
    return command.executeOnServer(server);
  }

  /// This method drops a collection
  Future<Map<String, Object?>> modernDrop(String collectionNAme,
      {DropOptions? dropOptions, Map<String, Object>? rawOptions}) async {
    var command = DropCommand(this, collectionNAme,
        dropOptions: dropOptions, rawOptions: rawOptions);
    return command.execute();
  }

  /// Runs a specified admin/diagnostic pipeline which does not require an
  /// underlying collection. For aggregations on collection data,
  /// see `dbcollection.modernAggregate()`.
  Stream<Map<String, dynamic>> aggregate(List<Map<String, Object>> pipeline,
      {bool? explain,
      Map<String, Object>? cursor,
      String? hint,
      Map<String, Object>? hintDocument,
      AggregateOptions? aggregateOptions,
      Map<String, Object>? rawOptions}) {
    return ModernCursor(
            AggregateOperation(pipeline,
                db: this,
                explain: explain,
                cursor: cursor,
                hint: hint,
                hintDocument: hintDocument,
                aggregateOptions: aggregateOptions,
                rawOptions: rawOptions),
            server)
        .stream;
  }

  /// Ping command
  Future<MongoDocument> pingCommand() => PingCommand(mongoClient.topology ??
          (throw MongoDartError('Topology not defined')))
      .execute();
}
