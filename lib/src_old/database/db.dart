part of mongo_dart;

class Db {
  static const mongoDefaultPort = 27017;
  final _log = Logger('Db');
  final List<String> _uriList = <String>[];

  State state = State.init;
  String? databaseName;
  String? _debugInfo;
  Db? authSourceDb;
  ConnectionManager? _connectionManager;

  ConnectionMultiRequest? get _masterConnection =>
      _connectionManager?.masterConnection;

  ConnectionMultiRequest get _masterConnectionVerified {
    if (state != State.open) {
      throw MongoDartError('Db is in the wrong state: $state');
    }
    return _masterConnectionVerifiedAnyState;
  }

  ConnectionMultiRequest get _masterConnectionVerifiedAnyState {
    if (_connectionManager == null) {
      throw MongoDartError('Invalid Connection manager state');
    }
    return _connectionManager!.masterConnectionVerified;
  }

  WriteConcern? _writeConcern;
  AuthenticationScheme? authenticationScheme;
  ReadPreference readPreference = ReadPreference.primary;

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
  Db(String uriString, [this._debugInfo]) {
    if (uriString.contains(',')) {
      _uriList.addAll(splitHosts(uriString));
    } else {
      _uriList.add(uriString);
    }
  }

  Db.pool(List<String> uriList, [this._debugInfo]) {
    _uriList.addAll(uriList);
  }

  Db._authDb(this.databaseName);

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
  static Future<Db> create(String uriString, [String? debugInfo]) async {
    if (uriString.startsWith('mongodb://')) {
      return Db(uriString, debugInfo);
    } else if (uriString.startsWith('mongodb+srv://')) {
      var uriList = await dnsLookup(Uri.parse(uriString));
      return Db.pool(uriList, debugInfo);
    } else {
      throw MongoDartError(
          'The only valid schemas for Db are: "mongodb" and "mongodb+srv".');
    }
  }

  WriteConcern? get writeConcern => _writeConcern;

  ConnectionMultiRequest get masterConnection => _masterConnectionVerified;
  ConnectionMultiRequest get masterConnectionAnyState =>
      _masterConnectionVerifiedAnyState;

  List<String> get uriList => _uriList.toList();

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
      serverConfig.port = mongoDefaultPort;
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
  }

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

  DbCollection collection(String collectionName) {
    return DbCollection(this, collectionName);
  }

  Future<MongoReplyMessage> queryMessage(MongoMessage queryMessage,
      {ConnectionMultiRequest? connection}) {
    return Future.sync(() {
      if (state != State.open) {
        throw MongoDartError('Db is in the wrong state: $state');
      }

      connection ??= masterConnection;

      return connection!.query(queryMessage);
    });
  }

  void executeMessage(MongoMessage message, WriteConcern? writeConcern,
      {ConnectionMultiRequest? connection}) {
    if (state != State.open) {
      throw MongoDartError('DB is not open. $state');
    }

    connection ??= _masterConnectionVerified;

    writeConcern ??= _writeConcern;

    // ignore: deprecated_member_use_from_same_package
    connection.execute(message, writeConcern == WriteConcern.ERRORS_IGNORED);
  }

  Future<Map<String, Object?>> executeModernMessage(MongoModernMessage message,
      {ConnectionMultiRequest? connection, bool skipStateCheck = false}) async {
    if (skipStateCheck) {
      if (!_masterConnectionVerifiedAnyState.serverCapabilities.supportsOpMsg) {
        throw MongoDartError('The "modern message" can only be executed '
            'starting from release 3.6');
      }
    } else {
      if (state != State.open) {
        throw MongoDartError('DB is not open. $state');
      }
      if (!masterConnection.serverCapabilities.supportsOpMsg) {
        throw MongoDartError('The "modern message" can only be executed '
            'starting from release 3.6');
      }
    }

    connection ??= _masterConnectionVerifiedAnyState;

    var response = await connection.executeModernMessage(message);

    var section = response.sections.firstWhere((Section section) =>
        section.payloadType == MongoModernMessage.basePayloadType);
    return section.payload.content;
  }

  Future open(
      {WriteConcern writeConcern = WriteConcern.acknowledged,
      bool secure = false,
      bool tlsAllowInvalidCertificates = false,
      String? tlsCAFile,
      String? tlsCertificateKeyFile,
      String? tlsCertificateKeyFilePassword}) async {
    if (state == State.opening) {
      throw MongoDartError('Attempt to open db in state $state');
    }

    state = State.opening;
    _writeConcern = writeConcern;
    _connectionManager = ConnectionManager(this);

    for (var uri in _uriList) {
      _connectionManager!.addConnection(await _parseUri(uri,
          isSecure: secure,
          tlsAllowInvalidCertificates: tlsAllowInvalidCertificates,
          tlsCAFile: tlsCAFile,
          tlsCertificateKeyFile: tlsCertificateKeyFile,
          tlsCertificateKeyFilePassword: tlsCertificateKeyFilePassword));
    }
    try {
      await _connectionManager!.open(writeConcern);
    } catch (e) {
      state = State.init;
      await _connectionManager!.close();
      rethrow;
    }
  }

  /// Is connected returns true if the database is in state `OPEN`
  /// and at least the primary connection is connected
  ///
  /// Connections can disconect because of network or database server problems.
  bool get isConnected =>
      state == State.open && (_masterConnection?.connected ?? false);

  Future<Map<String, dynamic>> executeDbCommand(MongoMessage message,
      {ConnectionMultiRequest? connection}) async {
    connection ??= _masterConnectionVerified;

    //var result = Completer<Map<String, dynamic>>();

    var replyMessage = await connection.query(message);
    if (replyMessage.documents == null || replyMessage.documents!.isEmpty) {
      throw {
        keyOk: 0.0,
        keyErrmsg:
            'Error executing Db command, documents are empty $replyMessage'
      };
    }
    var firstRepliedDocument = replyMessage.documents!.first;
    /*var errorMessage = '';

     if (replyMessage.documents.isEmpty) {
      errorMessage =
          'Error executing Db command, documents are empty $replyMessage';

      print('Error: $errorMessage');

      var m = <String, dynamic>{};
      m['errmsg'] = errorMessage;

      result.completeError(m);
    } else  */
    if (documentIsNotAnError(firstRepliedDocument)) {
      //result.complete(firstRepliedDocument);
      return firstRepliedDocument;
    } //else {

    //result.completeError(firstRepliedDocument);
    throw firstRepliedDocument;
    //}
    //return result.future;
  }

  bool documentIsNotAnError(firstRepliedDocument) =>
      firstRepliedDocument['ok'] == 1.0 && firstRepliedDocument['err'] == null;

  Future<bool> dropCollection(String collectionName) async {
    if (masterConnection.serverCapabilities.supportsOpMsg) {
      var result = await modernDrop(collectionName);
      return result[keyOk] == 1.0;
    }
    var collectionInfos = await getCollectionInfos({'name': collectionName});

    if (collectionInfos.length == 1) {
      return executeDbCommand(
              DbCommand.createDropCollectionCommand(this, collectionName))
          .then((_) => true);
    }

    return true;
  }

  ///   Drop current database
  Future drop() async {
    if (masterConnection.serverCapabilities.supportsOpMsg) {
      var result = await modernDropDatabase();
      return result[keyOk] == 1.0;
    }
    return executeDbCommand(DbCommand.createDropDatabaseCommand(this));
  }

  Future<Map<String, dynamic>> removeFromCollection(String collectionName,
      [Map<String, dynamic> selector = const {},
      WriteConcern? writeConcern]) async {
    if (_masterConnectionVerified.serverCapabilities.supportsOpMsg) {
      var collection = this.collection(collectionName);
      var result = await collection.deleteMany(
        selector,
        writeConcern: writeConcern,
      );
      return result.serverResponses.first;
    }
    return Future.sync(() {
      executeMessage(
          MongoRemoveMessage('$databaseName.$collectionName', selector),
          writeConcern);
      return _getAcknowledgement(writeConcern: writeConcern);
    });
  }

  Future<Map<String, dynamic>> getLastError(
      [WriteConcern? writeConcern]) async {
    writeConcern ??= _writeConcern;
    if (masterConnection.serverCapabilities.supportsOpMsg) {
      return GetLastErrorCommand(this, writeConcern: writeConcern).execute();
    } else {
      return executeDbCommand(
          DbCommand.createGetLastErrorCommand(this, writeConcern));
    }
  }

  @Deprecated('Deprecated since version 4.0.')
  Future<Map<String, dynamic>> getNonce({ConnectionMultiRequest? connection}) {
    if (masterConnection.serverCapabilities.fcv != null &&
        masterConnection.serverCapabilities.fcv!.compareTo('6.0') >= 0) {
      throw MongoDartError('getnonce command not managed in this version');
    }
    return executeDbCommand(DbCommand.createGetNonceCommand(this),
        connection: connection);
  }

  Future<Map<String, dynamic>> getBuildInfo(
      {ConnectionMultiRequest? connection}) {
    return executeDbCommand(DbCommand.createBuildInfoCommand(this),
        connection: connection);
  }

  Future<Map<String, dynamic>> isMaster({ConnectionMultiRequest? connection}) =>
      executeDbCommand(DbCommand.createIsMasterCommand(this),
          connection: connection);

  Future<Map<String, dynamic>> wait() => getLastError();

  Future close() async {
    _log.fine(() => '$this closed');
    state = State.closed;
    var cm = _connectionManager;
    _connectionManager = null;
    return cm?.close();
  }

  /// Analogue to shell's `show dbs`. Helper for `listDatabases` mongodb command.
  Future<List> listDatabases() async {
    var commandResult = await executeDbCommand(
        DbCommand.createQueryAdminCommand({'listDatabases': 1}));

    var result = [];

    for (var each in commandResult['databases']) {
      result.add(each['name']);
    }

    return result;
  }

  Stream<Map<String, dynamic>> _listCollectionsCursor(
      [Map<String, dynamic> filter = const {}]) {
    if (masterConnection.serverCapabilities.listCollections) {
      return ListCollectionsCursor(this, filter).stream;
    } else {
      // Using system collections (pre v3.0 API)
      var selector = <String, dynamic>{};
      // If we are limiting the access to a specific collection name
      if (filter.containsKey('name')) {
        selector['name'] = "$databaseName.${filter['name']}";
      }
      return Cursor(
              this,
              DbCollection(this, DbCommand.SYSTEM_NAMESPACE_COLLECTION),
              selector)
          .stream;
    }
  }

  /// This method uses system collections and therefore do not work on MongoDB v3.0 with and upward
  /// with WiredTiger
  /// Use `getCollectionInfos` instead
  @Deprecated('Use `getCollectionInfos` instead')
  Stream<Map<String, dynamic>> collectionsInfoCursor(
          [String? collectionName]) =>
      _collectionsInfoCursor(collectionName);

  Stream<Map<String, dynamic>> _collectionsInfoCursor(
      [String? collectionName]) {
    var selector = <String, dynamic>{};
    // If we are limiting the access to a specific collection name
    if (collectionName != null) {
      selector['name'] = '$databaseName.$collectionName';
    }
    // Return Cursor
    return Cursor(this,
            DbCollection(this, DbCommand.SYSTEM_NAMESPACE_COLLECTION), selector)
        .stream;
  }

  /// Analogue to shell's `show collections`
  /// This method uses system collections and therefore do not work on MongoDB v3.0 with and upward
  /// with WiredTiger
  /// Use `getCollectionNames` instead
  @Deprecated('Use `getCollectionNames` instead')
  Future<List<String?>> listCollections() async {
    if (masterConnection.serverCapabilities.supportsOpMsg) {
      var ret = await modernListCollections().toList();

      return [
        for (var element in ret)
          for (var nameKey in element.keys)
            if (nameKey == keyName) element[keyName]
      ];
    }
    return _collectionsInfoCursor()
        .map((map) => map['name']?.toString().split('.'))
        .where((arr) => arr != null && arr.length == 2)
        .map((arr) => arr?.last)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getCollectionInfos(
      [Map<String, dynamic> filter = const {}]) async {
    if (masterConnection.serverCapabilities.supportsOpMsg) {
      return modernListCollections(filter: filter).toList();
    }
    return _listCollectionsCursor(filter).toList();
  }

  Future<List<String?>> getCollectionNames(
      [Map<String, dynamic> filter = const {}]) async {
    if (masterConnection.serverCapabilities.supportsOpMsg) {
      var ret = await modernListCollections().toList();

      return [
        for (var element in ret)
          for (var nameKey in element.keys)
            if (nameKey == keyName) element[keyName]
      ];
    }
    return _listCollectionsCursor(filter)
        .map((map) => map['name']?.toString())
        .toList();
  }

  Future<bool> authenticate(String userName, String password,
      {ConnectionMultiRequest? connection}) async {
    var credential = UsernamePasswordCredential()
      ..username = userName
      ..password = password;

    (connection ?? masterConnection).serverConfig.userName ??= userName;
    (connection ?? masterConnection).serverConfig.password ??= password;

    if (authenticationScheme == null) {
      throw MongoDartError('Authentication scheme not specified');
    }
    var authenticator =
        Authenticator.create(authenticationScheme!, this, credential);

    await authenticator.authenticate(connection ?? masterConnection);

    (connection ?? masterConnection).serverConfig.isAuthenticated = true;
    return true;
  }

  /// This method uses system collections and therefore do not work on MongoDB v3.0 with and upward
  /// with WiredTiger
  /// Use `DbCollection.getIndexes()` instead
  @Deprecated('Use `DbCollection.getIndexes()` instead')
  Future<List> indexInformation([String? collectionName]) {
    var selector = {};

    if (collectionName != null) {
      selector['ns'] = '$databaseName.$collectionName';
    }

    return Cursor(this, DbCollection(this, DbCommand.SYSTEM_INDEX_COLLECTION),
            selector)
        .stream
        .toList();
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
    if (masterConnection.serverCapabilities.supportsOpMsg) {
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
    return Future.sync(() async {
      var selector = <String, dynamic>{};
      selector['ns'] = '$databaseName.$collectionName';
      keys = _setKeys(key, keys);
      selector['key'] = keys;

      if (unique == true) {
        selector['unique'] = true;
      } else {
        selector['unique'] = false;
      }
      if (sparse == true) {
        selector['sparse'] = true;
      }
      if (background == true) {
        selector['background'] = true;
      }
      if (dropDups == true) {
        selector['dropDups'] = true;
      }
      if (partialFilterExpression != null) {
        selector['partialFilterExpression'] = partialFilterExpression;
      }
      name ??= _createIndexName(keys!);
      selector['name'] = name;
      var insertMessage = MongoInsertMessage(
          '$databaseName.${DbCommand.SYSTEM_INDEX_COLLECTION}', [selector]);
      executeMessage(insertMessage, _writeConcern);
      return getLastError();
    });
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

  Future<Map<String, dynamic>> _getAcknowledgement(
      {WriteConcern? writeConcern}) {
    writeConcern ??= _writeConcern;

    // ignore: deprecated_member_use_from_same_package
    if (writeConcern == WriteConcern.ERRORS_IGNORED) {
      return Future.value({'ok': 1.0});
    } else {
      return getLastError(writeConcern);
    }
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
    if (!masterConnection.serverCapabilities.supportsOpMsg) {
      return <String, Object>{};
    }
    var operation = ServerStatusCommand(this,
        serverStatusOptions: ServerStatusOptions.instance);
    return operation.execute();
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

    return ModernCursor(command).stream;
  }

  /// This method creates a view
  Future<Map<String, Object?>> createView(
      String view, String source, List pipeline,
      {CreateViewOptions? createViewOptions,
      Map<String, Object>? rawOptions}) async {
    var command = CreateViewCommand(this, view, source, pipeline,
        createViewOptions: createViewOptions, rawOptions: rawOptions);
    return command.execute();
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
    if (!masterConnection.serverCapabilities.supportsOpMsg) {
      throw MongoDartError('At least MongoDb version 3.6 is required '
          'to run the aggregate operation');
    }
    return ModernCursor(AggregateOperation(pipeline,
            db: this,
            explain: explain,
            cursor: cursor,
            hint: hint,
            hintDocument: hintDocument,
            aggregateOptions: aggregateOptions,
            rawOptions: rawOptions))
        .stream;
  }

  /// Runs a command
  Future<Map<String, Object?>> runCommand(Map<String, Object>? command) =>
      CommandOperation(this, <String, Object>{}, command: command).execute();

  /// Ping command
  Future<Map<String, Object?>> pingCommand() => PingCommand(this).execute();
}
