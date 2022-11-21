//part of mongo_dart;

import 'package:logging/logging.dart';
import 'package:sasl_scram/sasl_scram.dart' show UsernamePasswordCredential;

import '../../mongo_dart_old.dart'
    show
        AggregateOperation,
        AggregateOptions,
        CreateCollectionCommand,
        CreateCollectionOptions,
        CreateViewCommand,
        CreateViewOptions,
        GetLastErrorCommand,
        ReadPreference,
        SelectorBuilder,
        ServerStatusCommand,
        ServerStatusOptions,
        State,
        key$Query,
        keyName,
        keyOk;
import '../core/auth/auth.dart';
import '../../src_old/auth/mongodb_cr_authenticator.dart';
import '../core/auth/scram_sha1_authenticator.dart';
import '../core/auth/scram_sha256_authenticator.dart';
import '../commands/administration_commands/drop_command/drop_command.dart';
import '../commands/administration_commands/drop_command/drop_options.dart';
import '../commands/administration_commands/drop_database_command/drop_database_command.dart';
import '../commands/administration_commands/drop_database_command/drop_database_options.dart';
import '../commands/administration_commands/list_collections_command/list_collections_command.dart';
import '../commands/administration_commands/list_collections_command/list_collections_options.dart';
import '../commands/diagnostic_commands/ping_command/ping_command.dart';
import 'modern_cursor.dart';
import '../../src_old/database/utils/dns_lookup.dart';
import '../commands/base/command_operation.dart';
import '../core/error/mongo_dart_error.dart';
import '../core/message/abstract/mongo_message.dart';
import '../core/message/deprecated/mongo_reply_message.dart';
import '../core/message/mongo_modern_message.dart';
import '../core/network/abstract/connection_base.dart';
import '../topology/server.dart';
import '../mongo_client.dart';
import '../utils/split_hosts.dart';
import '../parameters/write_concern.dart';
import 'mongo_collection.dart';

class MongoDatabase {
  final log = Logger('Db');
  final List<String> _uriList = <String>[];
  late MongoClient mongoClient;

  State state = State.init;
  String? databaseName;
  String? _debugInfo;
  MongoDatabase? authSourceDb;

  WriteConcern? _writeConcern;
  AuthenticationScheme? authenticationScheme;
  ReadPreference readPreference = ReadPreference.primary;

  //Todo temp solution
  Server get server => mongoClient.topology!.getServer(ReadPreference.primary);

  @override
  String toString() => 'Db($databaseName,$_debugInfo)';

  /// Db constructor expects [valid mongodb URI](https://docs.mongodb.com/manual/reference/connection-string/).
  /// For example next code points to local mongodb server on default mongodb port, database *testdb*
  ///```dart
  ///     var db = new Db('mongodb://127.0.0.1/testdb');
  ///```
  /// And that code direct to MongoLab server on 37637 port, database *testdb*, username *dart*, password *test*
  ///```dart
  ///     var db = new Db('mongodb://dart:test@ds037637-a.mongolab.com:37637/objectory_blog');
  ///```
  @Deprecated('No more used')
  MongoDatabase(String uriString, [this._debugInfo]) {
    if (uriString.contains(',')) {
      _uriList.addAll(splitHosts(uriString));
    } else {
      _uriList.add(uriString);
    }
  }
  @Deprecated('No more used')
  MongoDatabase.pool(List<String> uriList, [this._debugInfo]) {
    _uriList.addAll(uriList);
  }
  //@Deprecated('No more used')
  //Db._authDb(this.databaseName);

  MongoDatabase.modern(this.mongoClient, this.databaseName);

  /// This method allow to create a Db object both with the Standard
  /// Connection String Format (`mongodb://`) or with the DNS Seedlist
  /// Connection Format (`mongodb+srv://`).
  /// The former has the format:
  /// mongodb://[username:password@]host1[:port1]
  ///      [,...hostN[:portN]][/[defaultauthdb][?options]]
  /// The latter is available from version 3.6. The format is:
  /// mongodb+srv://[username:password@]host1[:port1]
  ///      [/[databaseName][?options]]
  /// More info are available [here](https://docs.mongodb.com/manual/reference/connection-string/)
  ///
  /// This is an asynchronous constructor.
  /// In order to resolve the Seedlist, a call to a DNS server is needed
  /// If the DNS server is unreachable, the constructor throws an error.
  @Deprecated('No more used')
  static Future<MongoDatabase> create(String uriString,
      [String? debugInfo]) async {
    if (uriString.startsWith('mongodb://')) {
      return MongoDatabase(uriString, debugInfo);
    } else if (uriString.startsWith('mongodb+srv://')) {
      var uriList = await dnsLookup(Uri.parse(uriString));
      return MongoDatabase.pool(uriList, debugInfo);
    } else {
      throw MongoDartError(
          'The only valid schemas for Db are: "mongodb" and "mongodb+srv".');
    }
  }

  WriteConcern? get writeConcern => _writeConcern;

  List<String> get uriList => _uriList.toList();
/* 
  Future<ServerConfig> _parseUri(String uriString,
      {bool? isSecure,
      bool? tlsAllowInvalidCertificates,
      String? tlsCAFile,
      String? tlsCertificateKeyFile,
      String? tlsCertificateKeyFilePassword}) async {
    isSecure ??= false;
    tlsAllowInvalidCertificates ??= false;
    if (tlsAllowInvalidCertificates ||
        tlsCAFile != null ||
        tlsCertificateKeyFile != null) {
      isSecure = true;
    }
    var uri = Uri.parse(uriString);

    if (uri.scheme != 'mongodb') {
      throw MongoDartError('Invalid scheme in uri: $uriString ${uri.scheme}');
    }

    uri.queryParameters.forEach((String queryParam, String value) {
      if (queryParam == ConnectionStringOptions.authMechanism) {
        selectAuthenticationMechanism(value);
      }

      if (queryParam == ConnectionStringOptions.authSource) {
        authSourceDb = Db._authDb(value);
      }

      if ((queryParam == ConnectionStringOptions.tls ||
              queryParam == ConnectionStringOptions.ssl) &&
          value == 'true') {
        isSecure = true;
      }
      if (queryParam == ConnectionStringOptions.tlsAllowInvalidCertificates &&
          value == 'true') {
        tlsAllowInvalidCertificates = true;
        isSecure = true;
      }
      if (queryParam == ConnectionStringOptions.tlsCAFile && value.isNotEmpty) {
        tlsCAFile = value;
        isSecure = true;
      }
      if (queryParam == ConnectionStringOptions.tlsCertificateKeyFile &&
          value.isNotEmpty) {
        tlsCertificateKeyFile = value;
        isSecure = true;
      }
      if (queryParam == ConnectionStringOptions.tlsCertificateKeyFilePassword &&
          value.isNotEmpty) {
        tlsCertificateKeyFilePassword = value;
      }
    });

    Uint8List? tlsCAFileContent;
    if (tlsCAFile != null) {
      tlsCAFileContent = await File(tlsCAFile!).readAsBytes();
    }
    Uint8List? tlsCertificateKeyFileContent;
    if (tlsCertificateKeyFile != null) {
      tlsCertificateKeyFileContent =
          await File(tlsCertificateKeyFile!).readAsBytes();
    }
    if (tlsCertificateKeyFilePassword != null &&
        tlsCertificateKeyFile == null) {
      throw MongoDartError('Missing tlsCertificateKeyFile parameter');
    }

    var serverConfig = ServerConfig(
        host: uri.host,
        port: uri.port,
        isSecure: isSecure,
        tlsAllowInvalidCertificates: tlsAllowInvalidCertificates,
        tlsCAFileContent: tlsCAFileContent,
        tlsCertificateKeyFileContent: tlsCertificateKeyFileContent,
        tlsCertificateKeyFilePassword: tlsCertificateKeyFilePassword);

    if (serverConfig.port == 0) {
      serverConfig.port = defMongoPort;
    }

    if (uri.userInfo.isNotEmpty) {
      var userInfo = uri.userInfo.split(':');

      if (userInfo.length != 2) {
        throw MongoDartError('Invalid format of userInfo field: $uri.userInfo');
      }

      serverConfig.userName = Uri.decodeComponent(userInfo[0]);
      serverConfig.password = Uri.decodeComponent(userInfo[1]);
    }

    if (uri.path.isNotEmpty) {
      databaseName = uri.path.replaceAll('/', '');
    }
    if (unfilled(databaseName)) {
      databaseName = 'test';
    }

    return serverConfig;
  } */

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

  MongoCollection collection(String collectionName) {
    return MongoCollection(this, collectionName);
  }

  Future<MongoReplyMessage> queryMessage(MongoMessage queryMessage,
      {ConnectionBase? connection}) {
    throw MongoDartError('No More used');
  }

  void executeMessage(MongoMessage message, WriteConcern? writeConcern,
      {ConnectionBase? connection}) {
    throw MongoDartError('No More used');
  }

  Future<Map<String, Object?>> executeModernMessage(MongoModernMessage message,
      {ConnectionBase? connection}) async {
    if (state != State.open) {
      throw MongoDartError('DB is not open. $state');
    }

    return server.executeMessage(message);
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
    return GetLastErrorCommand(this, writeConcern: writeConcern)
        .executeOnServer(server);
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

  @Deprecated('No More Used')
  Future<Map<String, dynamic>> isMaster({ConnectionBase? connection}) =>
      throw MongoDartError('No More used');

  Future<Map<String, dynamic>> wait() => throw MongoDartError('No More used');

  @Deprecated('No More Used')
  Future close() async {
    throw MongoDartError('No More used');
  }

  // Todo new version ?
  /// Analogue to shell's `show dbs`. Helper for `listDatabases` mongodb command.
  ///   @Deprecated('No More Used')
  Future<List> listDatabases() async {
    throw MongoDartError('No More used');
  }
/* 
  @Deprecated('No More Used')
  Stream<Map<String, dynamic>> _listCollectionsCursor(
      [Map<String, dynamic> filter = const {}]) {
    throw MongoDartError('No More used');
  } */

  /// This method uses system collections and therefore do not work on MongoDB v3.0 with and upward
  /// with WiredTiger
  /// Use `getCollectionInfos` instead
  @Deprecated('Use `getCollectionInfos` instead')
  Stream<Map<String, dynamic>> collectionsInfoCursor(
          [String? collectionName]) =>
      _collectionsInfoCursor(collectionName);

  @Deprecated('No More Used')
  Stream<Map<String, dynamic>> _collectionsInfoCursor(
      [String? collectionName]) {
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

  /// This method uses system collections and therefore do not work on MongoDB v3.0 with and upward
  /// with WiredTiger
  /// Use `DbCollection.getIndexes()` instead
  @Deprecated('Use `DbCollection.getIndexes()` instead')
  Future<List> indexInformation([String? collectionName]) {
    throw MongoDartError('No More used');
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
/* 
  @Deprecated('No More Used')
  Future<Map<String, dynamic>> _getAcknowledgement(
      {WriteConcern? writeConcern}) {
    writeConcern ??= _writeConcern;
    throw MongoDartError('No More Used');
  } */

  // **********************************************************+
  // ************** OP_MSG_COMMANDS ****************************
  // ***********************************************************

  /// This method drops the current DB
  Future<Map<String, Object?>> modernDropDatabase(
      {DropDatabaseOptions? dropOptions,
      Map<String, Object>? rawOptions}) async {
    var command = DropDatabaseCommand(this,
        dropDatabaseOptions: dropOptions, rawOptions: rawOptions);
    return command.executeOnServer(server);
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
    return command.executeOnServer(server);
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
    return command.executeOnServer(server);
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

  /// Runs a command
  Future<Map<String, Object?>> runCommand(Map<String, Object> command) =>
      CommandOperation(
        this,
        command,
        <String, Object>{},
      ).executeOnServer(server);

  /// Ping command
  Future<Map<String, Object?>> pingCommand() =>
      PingCommand(mongoClient.topology ??
              (throw MongoDartError('Topology not defined')))
          .executeOnServer(server);
}
