part of mongo_dart;

/// [WriteConcern] control the acknowledgment of write operations with various paramaters.
class WriteConcern {
  /// Denotes the Write Concern level that takes the following values
  /// ([int] or [String]):
  /// - -1 Disables all acknowledgment of write operations, and suppresses
  /// all errors, including network and socket errors.
  /// - 0: Disables basic acknowledgment of write operations, but returns
  /// information about socket exceptions and networking errors to the
  /// application.
  /// - 1: Provides acknowledgment of write operations on a standalone mongod
  /// or the primary in a replica set.
  /// - A number greater than 1: Guarantees that write operations have
  /// propagated successfully to the specified number of replica set members
  /// including the primary.
  /// - "majority": Confirms that write operations have propagated to the
  /// majority of configured replica set
  /// - A tag set: Fine-grained control over which replica set members must
  /// acknowledge a write operation
  final w;

  /// Specifies a timeout for this Write Concern in milliseconds,
  /// or infinite if equal to 0.
  final int wtimeout;

  /// Enables or disable fsync() operation before acknowledgement of
  /// the requested write operation.
  /// If [true], wait for mongod instance to write data to disk before returning.
  final bool fsync;

  /// Enables or disable journaling of the requested write operation before
  /// acknowledgement.
  /// If [true], wait for mongod instance to write data to the on-disk journal
  /// before returning.
  final bool j;

  /// A string value indicating where the write concern originated
  /// (known as write concern provenance). The following table shows the
  /// possible values for this field and their significance:
  ///
  /// **Provenance** -  **Description**
  /// - clientSupplied
  ///   - The write concern was specified in the application.
  /// - customDefault
  ///   - The write concern originated from a custom defined default value. See setDefaultRWConcern.
  /// - getLastErrorDefaults
  ///   - The write concern originated from the replica set’s settings.getLastErrorDefaults field.
  /// - implicitDefault
  ///   - The write concern originated from the server in absence of all other write concern specifications.
  ///
  /// ** NOTE **
  ///
  /// This field is *only* set by the database when the Write concern is
  /// returned in a writeConcernError. It is **NOT** to be sent to the server
  final String provenance;

  /// Creates a WriteConcern object
  const WriteConcern(
      {this.w, this.wtimeout, this.fsync, this.j, this.provenance});

  WriteConcern.fromMap(Map<String, Object> writeConcernMap)
      : w = writeConcernMap[keyW],
        wtimeout = writeConcernMap[keyWtimeout],
        fsync = writeConcernMap[keyFsync],
        j = writeConcernMap[keyJ],
        provenance = writeConcernMap[keyProvenance];

  /// No exceptions are raised, even for network issues.
  @deprecated
  static const ERRORS_IGNORED =
      WriteConcern(w: -1, wtimeout: 0, fsync: false, j: false);

  /// Write operations that use this write concern will return as soon as the
  /// message is written to the socket.
  /// Exceptions are raised for network issues, but not server errors.
  static const UNACKNOWLEDGED =
      WriteConcern(w: 0, wtimeout: 0, fsync: false, j: false);

  /// Write operations that use this write concern will wait for
  /// acknowledgement from the primary server before returning.
  /// Exceptions are raised for network issues, and server errors.
  static const ACKNOWLEDGED =
      WriteConcern(w: 1, wtimeout: 0, fsync: false, j: false);

  /// Exceptions are raised for network issues, and server errors;
  /// waits for at least 2 servers for the write operation.
  static const REPLICA_ACKNOWLEDGED =
      WriteConcern(w: 2, wtimeout: 0, fsync: false, j: false);

  /// Exceptions are raised for network issues, and server errors;
  /// the write operation waits for the server to flush
  /// the data to disk.
  @deprecated
  static const FSYNCED = WriteConcern(w: 1, wtimeout: 0, fsync: true, j: false);

  /// Exceptions are raised for network issues, and server errors; the write
  /// operation waits for the server to
  /// group commit to the journal file on disk.
  static const JOURNALED =
      WriteConcern(w: 1, wtimeout: 0, fsync: false, j: true);

  /// Exceptions are raised for network issues, and server errors; waits on a
  /// majority of servers for the write operation.
  static const MAJORITY =
      WriteConcern(w: 'majority', wtimeout: 0, fsync: false, j: false);

  /// Gets the getlasterror command for this write concern.
  Map<String, dynamic> get command {
    var map = <String, dynamic>{};
    map['getlasterror'] = 1;
    if (w != null) {
      map['w'] = w;
    }
    if (wtimeout != null) {
      map['wtimeout'] = wtimeout;
    }
    if (fsync != null) {
      map['fsync'] = fsync;
    }
    if (j != null) {
      map['j'] = j;
    }
    return map;
  }

  /// To be used starting with journaled engines (Only Wired Tiger, Journal Only)
  /// For inMemoryEngine the J option is ignored
  ///
  /// We can use before 4.2 testing if the journal is active
  /// (in this case fsync doesn't make any sense, taken from mongodb Jira:
  /// "fsync means sync using a journal if present otherwise the datafiles")
  /// In 4.0 journal cannot be disabled on wiredTiger engine
  /// In 4.2 only wiredTiger can be used
  Map<String, Object> asMap(ServerStatus serverStatus) {
    var ret = <String, Object>{};
    if (w != null) {
      ret[keyW] = w;
    }
    if (wtimeout != null) {
      ret[keyWtimeout] = wtimeout;
    }
    if (serverStatus.isPersistent) {
      if (j != null) {
        ret[keyJ] = j;
      }
      if (fsync != null && j != true) {
        if (serverStatus.isJournaled) {
          ret[keyJ] = fsync;
        } else {
          ret[keyFsync] = fsync;
        }
      }
    }
    return ret;
  }
}

class _UriParameters {
  static const authMechanism = 'authMechanism';
  static const authSource = 'authSource';
  static const tls = 'tls';
  static const ssl = 'ssl';
}

class Db {
  static const mongoDefaultPort = 27017;
  final _log = Logger('Db');
  final List<String> _uriList = <String>[];

  State state = State.INIT;
  String databaseName;
  String _debugInfo;
  Db authSourceDb;
  _ConnectionManager _connectionManager;

  Connection get _masterConnection => _connectionManager.masterConnection;

  Connection get _masterConnectionVerified {
    if (state != State.OPEN) {
      throw MongoDartError('Db is in the wrong state: ${state}');
    }
    return _connectionManager.masterConnectionVerified;
  }

  WriteConcern _writeConcern;
  AuthenticationScheme _authenticationScheme;
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
  static Future<Db> create(String uriString, [String _debugInfo]) async {
    if (uriString.startsWith('mongodb://')) {
      return Db(uriString, _debugInfo);
    } else if (uriString.startsWith('mongodb+srv://')) {
      var uriList = await decodeDnsSeedlist(Uri.parse(uriString));
      return Db.pool(uriList, _debugInfo);
    } else {
      throw MongoDartError(
          'The only valid schemas for Db are: "mongodb" and "mongodb+srv".');
    }
  }

  WriteConcern get writeConcern => _writeConcern;

  Connection get masterConnection => _connectionManager.masterConnection;

  List<String> get uriList => _uriList.toList();

  ServerConfig _parseUri(String uriString, {bool isSecure}) {
    isSecure ??= false;
    var uri = Uri.parse(uriString);

    if (uri.scheme != 'mongodb') {
      throw MongoDartError('Invalid scheme in uri: $uriString ${uri.scheme}');
    }

    uri.queryParameters.forEach((String queryParam, String value) {
      if (queryParam == _UriParameters.authMechanism) {
        selectAuthenticationMechanism(value);
      }

      if (queryParam == _UriParameters.authSource) {
        authSourceDb = Db._authDb(value);
      }

      if ((queryParam == _UriParameters.tls ||
              queryParam == _UriParameters.ssl) &&
          value == 'true') {
        isSecure = true;
      }
    });

    var serverConfig = ServerConfig(
        uri.host ?? '127.0.0.1', uri.port ?? mongoDefaultPort, isSecure);

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

    return serverConfig;
  }

  void selectAuthenticationMechanism(String authenticationSchemeName) {
    if (authenticationSchemeName == ScramSha1Authenticator.name) {
      _authenticationScheme = AuthenticationScheme.SCRAM_SHA_1;
    } else if (authenticationSchemeName == MongoDbCRAuthenticator.name) {
      _authenticationScheme = AuthenticationScheme.MONGODB_CR;
    } else {
      throw MongoDartError(
          'Provided authentication scheme is not supported : $authenticationSchemeName');
    }
  }

  DbCollection collection(String collectionName) {
    return DbCollection(this, collectionName);
  }

  Future<MongoReplyMessage> queryMessage(MongoMessage queryMessage,
      {Connection connection}) {
    return Future.sync(() {
      if (state != State.OPEN) {
        throw MongoDartError('Db is in the wrong state: $state');
      }

      connection ??= _masterConnectionVerified;

      return connection.query(queryMessage);
    });
  }

  void executeMessage(MongoMessage message, WriteConcern writeConcern,
      {Connection connection}) {
    if (state != State.OPEN) {
      throw MongoDartError('DB is not open. $state');
    }

    connection ??= _masterConnectionVerified;

    writeConcern ??= _writeConcern;

    connection.execute(message, writeConcern == WriteConcern.ERRORS_IGNORED);
  }

  Future<Map<String, Object>> executeModernMessage(MongoModernMessage message,
      {Connection connection}) async {
    if (state != State.OPEN) {
      throw MongoDartError('DB is not open. $state');
    }
    if (!_masterConnection.serverCapabilities.supportsOpMsg) {
      throw MongoDartError('The "modern message" can only be executed '
          'starting from release 3.6');
    }

    connection ??= _masterConnectionVerified;

    var response = await connection.executeModernMessage(message);

    var section = response.sections.firstWhere((Section _section) =>
        _section.payloadType == MongoModernMessage.basePayloadType);
    return section.payload.content;
  }

  Future open(
      {WriteConcern writeConcern = WriteConcern.ACKNOWLEDGED,
      bool secure = false}) async {
    if (state == State.OPENING) {
      throw MongoDartError('Attempt to open db in state $state');
    }

    state = State.OPENING;
    _writeConcern = writeConcern;
    _connectionManager = _ConnectionManager(this);

    for (var uri in _uriList) {
      _connectionManager.addConnection(_parseUri(uri, isSecure: secure));
    }
    try {
      await _connectionManager.open(writeConcern);
    } catch (e) {
      state = State.INIT;
      await _connectionManager.close();
      rethrow;
    }
  }

  /// Is connected returns true if the database is in state `OPEN`
  /// and at least the primary connection is connected
  ///
  /// Connections can disconect because of network or database server problems.
  bool get isConnected =>
      state == State.OPEN && (_masterConnection?.connected ?? false);

  Future<Map<String, dynamic>> executeDbCommand(MongoMessage message,
      {Connection connection}) async {
    connection ??= _masterConnectionVerified;

    var result = Completer<Map<String, dynamic>>();

    var replyMessage = await connection.query(message);
    var firstRepliedDocument = replyMessage.documents[0];
    var errorMessage = '';

    if (replyMessage.documents.isEmpty) {
      errorMessage =
          'Error executing Db command, documents are empty $replyMessage';

      print('Error: $errorMessage');

      var m = <String, dynamic>{};
      m['errmsg'] = errorMessage;

      result.completeError(m);
    } else if (documentIsNotAnError(firstRepliedDocument)) {
      result.complete(firstRepliedDocument);
    } else {
      result.completeError(firstRepliedDocument);
    }
    return result.future;
  }

  bool documentIsNotAnError(firstRepliedDocument) =>
      firstRepliedDocument['ok'] == 1.0 && firstRepliedDocument['err'] == null;

  Future<bool> dropCollection(String collectionName) async {
    var collectionInfos = await getCollectionInfos({'name': collectionName});

    if (collectionInfos.length == 1) {
      return executeDbCommand(
              DbCommand.createDropCollectionCommand(this, collectionName))
          .then((_) => true);
    }

    return true;
  }

  ///   Drop current database
  Future drop() {
    return executeDbCommand(DbCommand.createDropDatabaseCommand(this));
  }

  Future<Map<String, dynamic>> removeFromCollection(String collectionName,
      [Map<String, dynamic> selector = const {}, WriteConcern writeConcern]) {
    return Future.sync(() {
      executeMessage(
          MongoRemoveMessage('$databaseName.$collectionName', selector),
          writeConcern);
      return _getAcknowledgement(writeConcern: writeConcern);
    });
  }

  Future<Map<String, dynamic>> getLastError([WriteConcern writeConcern]) async {
    writeConcern ??= _writeConcern;
    if (_masterConnection.serverCapabilities.supportsOpMsg) {
      return GetLastErrorCommand(this, writeConcern: writeConcern).execute();
    } else {
      return executeDbCommand(
          DbCommand.createGetLastErrorCommand(this, writeConcern));
    }
  }

  Future<Map<String, dynamic>> getNonce({Connection connection}) {
    return executeDbCommand(DbCommand.createGetNonceCommand(this),
        connection: connection);
  }

  Future<Map<String, dynamic>> getBuildInfo({Connection connection}) {
    return executeDbCommand(DbCommand.createBuildInfoCommand(this),
        connection: connection);
  }

  Future<Map<String, dynamic>> isMaster({Connection connection}) {
    return executeDbCommand(DbCommand.createIsMasterCommand(this),
        connection: connection);
  }

  Future<Map<String, dynamic>> wait() {
    return getLastError();
  }

  Future close() {
    _log.fine(() => '$this closed');
    state = State.CLOSED;
    var _cm = _connectionManager;
    _connectionManager = null;
    return _cm.close();
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
    if (_masterConnection.serverCapabilities.listCollections) {
      return ListCollectionsCursor(this, filter).stream;
    } else {
      // Using system collections (pre v3.0 API)
      var selector = <String, dynamic>{};
      // If we are limiting the access to a specific collection name
      if (filter.containsKey('name')) {
        selector['name'] = "${databaseName}.${filter['name']}";
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
  @deprecated
  Stream<Map<String, dynamic>> collectionsInfoCursor([String collectionName]) {
    return _collectionsInfoCursor(collectionName);
  }

  Stream<Map<String, dynamic>> _collectionsInfoCursor([String collectionName]) {
    var selector = <String, dynamic>{};
    // If we are limiting the access to a specific collection name
    if (collectionName != null) {
      selector['name'] = '${databaseName}.$collectionName';
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
  @deprecated
  Future<List<String>> listCollections() {
    return _collectionsInfoCursor()
        .map((map) => map['name']?.toString()?.split('.'))
        .where((arr) => arr.length == 2)
        .map((arr) => arr.last)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getCollectionInfos(
      [Map<String, dynamic> filter = const {}]) {
    return _listCollectionsCursor(filter).toList();
  }

  Future<List<String>> getCollectionNames(
      [Map<String, dynamic> filter = const {}]) {
    return _listCollectionsCursor(filter)
        .map((map) => map['name']?.toString())
        .toList();
  }

  Future<bool> authenticate(String userName, String password,
      {Connection connection}) async {
    var credential = UsernamePasswordCredential()
      ..username = userName
      ..password = password;

    var authenticator =
        createAuthenticator(_authenticationScheme, this, credential);

    await authenticator.authenticate(connection ?? _masterConnection);

    return true;
  }

  /// This method uses system collections and therefore do not work on MongoDB v3.0 with and upward
  /// with WiredTiger
  /// Use `DbCollection.getIndexes()` instead
  @deprecated
  Future<List> indexInformation([String collectionName]) {
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
      {String key,
      Map<String, dynamic> keys,
      bool unique,
      bool sparse,
      bool background,
      bool dropDups,
      Map<String, dynamic> partialFilterExpression,
      String name}) {
    if (_masterConnection.serverCapabilities.supportsOpMsg) {
      return collection(collectionName).createIndex(
          key: key,
          keys: keys,
          unique: unique,
          sparse: sparse,
          background: background,
          dropDups: dropDups,
          partialFilterExpression: partialFilterExpression,
          name: name,
          modernReply: false);
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
      name ??= _createIndexName(keys);
      selector['name'] = name;
      var insertMessage = MongoInsertMessage(
          '$databaseName.${DbCommand.SYSTEM_INDEX_COLLECTION}', [selector]);
      await executeMessage(insertMessage, _writeConcern);
      return getLastError();
    });
  }

  Map<String, dynamic> _setKeys(String key, Map<String, dynamic> keys) {
    if (key != null && keys != null) {
      throw ArgumentError('Only one parameter must be set: key or keys');
    }

    if (key != null) {
      keys = {};
      keys['$key'] = 1;
    }

    if (keys == null) {
      throw ArgumentError('key or keys parameter must be set');
    }

    return keys;
  }

  Future ensureIndex(String collectionName,
      {String key,
      Map<String, dynamic> keys,
      bool unique,
      bool sparse,
      bool background,
      bool dropDups,
      Map<String, dynamic> partialFilterExpression,
      String name}) async {
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
      {WriteConcern writeConcern}) {
    writeConcern ??= _writeConcern;

    if (writeConcern == WriteConcern.ERRORS_IGNORED) {
      return Future.value({'ok': 1.0});
    } else {
      return getLastError(writeConcern);
    }
  }

  // **********************************************************+
  // ************** OP_MSG_COMMANDS ****************************
  // ***********************************************************

  /// This method return the status information on the
  /// connection.
  ///
  /// Only works from version 3.6
  Future<Map<String, Object>> serverStatus(
      {Map<String, Object> options}) async {
    if (!_masterConnection.serverCapabilities.supportsOpMsg) {
      return <String, Object>{};
    }
    var operation = ServerStatusCommand(this);
    return operation.execute();
  }

  /// This method explicitly creates a collection
  Future<Map<String, Object>> createCollection(String name,
      {CreateCollectionOptions createCollectionOptions,
      Map<String, Object> rawOptions}) async {
    var command = CreateCollectionCommand(this, name,
        createCollectionOptions: createCollectionOptions,
        rawOptions: rawOptions);
    return command.execute();
  }

  /// This method creates a view
  Future<Map<String, Object>> createView(
      String view, String source, List pipeline,
      {CreateViewOptions createViewOptions,
      Map<String, Object> rawOptions}) async {
    var command = CreateViewCommand(this, view, source, pipeline,
        createViewOptions: createViewOptions, rawOptions: rawOptions);
    return command.execute();
  }
}
