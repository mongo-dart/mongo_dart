part of mongo_dart;

/**
 * [WriteConcern] control the acknowledgment of write operations with various paramaters.
 */
class WriteConcern {
  /**
   * Denotes the Write Concern level that takes the following values ([int] or [String]):
   *
   * * -1 Disables all acknowledgment of write operations, and suppresses all errors, including network and socket errors.
   * * 0: Disables basic acknowledgment of write operations, but returns information about socket exceptions and networking errors to the application.
   * * 1: Provides acknowledgment of write operations on a standalone mongod or the primary in a replica set.
   * * A number greater than 1: Guarantees that write operations have propagated successfully to the specified number of replica set members including the primary.
   * * "majority": Confirms that write operations have propagated to the majority of configured replica set
   * * A tag set: Fine-grained control over which replica set members must acknowledge a write operation
   */
  final w;

  /**
   * Specifies a timeout for this Write Concern in milliseconds, or infinite if equal to 0.
   */
  final int wtimeout;

  /**
   * Enables or disable fsync() operation before acknowledgement of the requested write operation.
   * If [true], wait for mongod instance to write data to disk before returning.
   */
  final bool fsync;

  /**
   * Enables or disable journaling of the requested write operation before acknowledgement.
   * If [true], wait for mongod instance to write data to the on-disk journal before returning.
   */
  final bool j;

  /**
   * Creates a WriteConcern object
   */
  const WriteConcern({this.w, this.wtimeout, this.fsync, this.j});

  /**
   * No exceptions are raised, even for network issues.
   */
  static const ERRORS_IGNORED =
      const WriteConcern(w: -1, wtimeout: 0, fsync: false, j: false);

  /**
   * Write operations that use this write concern will return as soon as the message is written to the socket.
   * Exceptions are raised for network issues, but not server errors.
   */
  static const UNACKNOWLEDGED =
      const WriteConcern(w: 0, wtimeout: 0, fsync: false, j: false);

  /**
   * Write operations that use this write concern will wait for acknowledgement from the primary server before returning.
   * Exceptions are raised for network issues, and server errors.
   */
  static const ACKNOWLEDGED =
      const WriteConcern(w: 1, wtimeout: 0, fsync: false, j: false);

  /**
   * Exceptions are raised for network issues, and server errors; waits for at least 2 servers for the write operation.
   */
  static const REPLICA_ACKNOWLEDGED =
      const WriteConcern(w: 2, wtimeout: 0, fsync: false, j: false);

  /**
   * Exceptions are raised for network issues, and server errors; the write operation waits for the server to flush
   * the data to disk.
   */
  static const FSYNCED =
      const WriteConcern(w: 1, wtimeout: 0, fsync: true, j: false);

  /**
   * Exceptions are raised for network issues, and server errors; the write operation waits for the server to
   * group commit to the journal file on disk.
   */
  static const JOURNALED =
      const WriteConcern(w: 1, wtimeout: 0, fsync: false, j: true);

  /**
   * Exceptions are raised for network issues, and server errors; waits on a majority of servers for the write operation.
   */
  static const MAJORITY =
      const WriteConcern(w: "majority", wtimeout: 0, fsync: false, j: false);

  /**
   * Gets the getlasterror command for this write concern.
   */
  Map get command {
    var map = new Map();
    map["getlasterror"] = 1;
    if (w != null) {
      map["w"] = w;
    }
    if (wtimeout != null) {
      map["wtimeout"] = wtimeout;
    }
    if (fsync != null) {
      map["fsync"] = fsync;
    }
    if (j != null) {
      map["j"] = j;
    }
    return map;
  }
}

class _UriParameters {
  static const authMechanism = 'authMechanism';
  static const authSource = 'authSource';
}

class Db {
  final MONGO_DEFAULT_PORT = 27017;
  final _log = new Logger('Db');
  final List<String> _uriList = new List<String>();

  State state = State.INIT;
  String databaseName;
  String _debugInfo;
  Db authSourceDb;
  _ConnectionManager _connectionManager;
  _Connection get _masterConnection => _connectionManager.masterConnection;
  _Connection get _masterConnectionVerified =>
      _connectionManager.masterConnectionVerified;
  WriteConcern _writeConcern;
  AuthenticationScheme _authenticationScheme;

  String toString() => 'Db($databaseName,$_debugInfo)';

  /**
  * Db constructor expects [valid mongodb URI] (http://www.mongodb.org/display/DOCS/Connections).
  * For example next code points to local mongodb server on default mongodb port, database *testdb*
  *     var db = new Db('mongodb://127.0.0.1/testdb');
  * And that code direct to MongoLab server on 37637 port, database *testdb*, username *dart*, password *test*
  *     var db = new Db('mongodb://dart:test@ds037637-a.mongolab.com:37637/objectory_blog');
  */
  Db(String uriString, [this._debugInfo]) {
    _uriList.add(uriString);
  }

  Db.pool(List<String> uriList, [this._debugInfo]) {
    _uriList.addAll(uriList);
  }
  Db._authDb(this.databaseName);
  ServerConfig _parseUri(String uriString) {
    var uri = Uri.parse(uriString);

    if (uri.scheme != 'mongodb') {
      throw new MongoDartError(
          'Invalid scheme in uri: $uriString ${uri.scheme}');
    }

    var serverConfig = new ServerConfig();
    serverConfig.host = uri.host;
    serverConfig.port = uri.port;

    if (serverConfig.port == null || serverConfig.port == 0) {
      serverConfig.port = MONGO_DEFAULT_PORT;
    }

    if (uri.userInfo.isNotEmpty) {
      var userInfo = uri.userInfo.split(':');

      if (userInfo.length != 2) {
        throw new MongoDartError(
            'Invalid format of userInfo field: $uri.userInfo');
      }

      serverConfig.userName = Uri.decodeComponent(userInfo[0]);
      serverConfig.password = Uri.decodeComponent(userInfo[1]);
    }

    if (uri.path.isNotEmpty) {
      databaseName = uri.path.replaceAll('/', '');
    }

    uri.queryParameters.forEach((String queryParam, String value) {
      if (queryParam == _UriParameters.authMechanism) {
        selectAuthenticationMechanism(value);
      }

      if (queryParam == _UriParameters.authSource) {
        authSourceDb = new Db._authDb(value);
      }
    });

    return serverConfig;
  }

  void selectAuthenticationMechanism(String authenticationSchemeName) {
    if (authenticationSchemeName == ScramSha1Authenticator.name) {
      _authenticationScheme = AuthenticationScheme.SCRAM_SHA_1;
    } else if (authenticationSchemeName == MongoDbCRAuthenticator.name) {
      _authenticationScheme = AuthenticationScheme.MONGODB_CR;
    } else {
      throw new MongoDartError(
          "Provided authentication scheme is not supported : $authenticationSchemeName");
    }
  }

  DbCollection collection(String collectionName) {
    return new DbCollection(this, collectionName);
  }

  Future queryMessage(MongoMessage queryMessage, {_Connection connection}) {
    return new Future.sync(() {
      if (state != State.OPEN) {
        throw new MongoDartError('Db is in the wrong state: $state');
      }

      if (connection == null) {
        connection = _masterConnectionVerified;
      }

      return connection.query(queryMessage);
    });
  }

  executeMessage(MongoMessage message, WriteConcern writeConcern,
      {_Connection connection}) {
    if (state != State.OPEN) {
      throw new MongoDartError('DB is not open. $state');
    }

    if (connection == null) {
      connection = _masterConnectionVerified;
    }

    if (writeConcern == null) {
      writeConcern = _writeConcern;
    }

    connection.execute(message, writeConcern == WriteConcern.ERRORS_IGNORED);
  }

  Future open({WriteConcern writeConcern: WriteConcern.ACKNOWLEDGED}) {
    return new Future.sync(() {
      if (state == State.OPENING) {
        throw new MongoDartError('Attempt to open db in state $state');
      }

      state = State.OPENING;
      _writeConcern = writeConcern;
      _connectionManager = new _ConnectionManager(this);

      _uriList.forEach((uri) {
        _connectionManager.addConnection(_parseUri(uri));
      });

      return _connectionManager.open(writeConcern);
    });
  }

  Future executeDbCommand(MongoMessage message,
      {_Connection connection}) async {
    if (connection == null) {
      connection = _masterConnectionVerified;
    }

    Completer<Map> result = new Completer();

    var replyMessage = await connection.query(message);
    var firstRepliedDocument = replyMessage.documents[0];
    var errorMessage = "";

    if (replyMessage.documents.isEmpty) {
      errorMessage =
          "Error executing Db command, documents are empty $replyMessage";

      print("Error: $errorMessage");

      var m = new Map();
      m["errmsg"] = errorMessage;

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

  Future dropCollection(String collectionName) async {
    var collectionInfos = await getCollectionInfos({'name': collectionName});

    if (collectionInfos.length == 1) {
      return executeDbCommand(
          DbCommand.createDropCollectionCommand(this, collectionName));
    }

    return true;
  }

  /**
  *   Drop current database
  */
  Future drop() {
    return executeDbCommand(DbCommand.createDropDatabaseCommand(this));
  }

  Future<Map> removeFromCollection(String collectionName,
      [Map selector = const {}, WriteConcern writeConcern]) {
    return new Future.sync(() {
      executeMessage(
          new MongoRemoveMessage("$databaseName.$collectionName", selector),
          writeConcern);
      return _getAcknowledgement(writeConcern: writeConcern);
    });
  }

  Future<Map> getLastError([WriteConcern writeConcern]) {
    if (writeConcern == null) {
      writeConcern = _writeConcern;
    }
    return executeDbCommand(
        DbCommand.createGetLastErrorCommand(this, writeConcern));
  }

  Future<Map> getNonce({_Connection connection}) {
    return executeDbCommand(DbCommand.createGetNonceCommand(this),
        connection: connection);
  }

  Future<Map> getBuildInfo({_Connection connection}) {
    return executeDbCommand(DbCommand.createBuildInfoCommand(this),
        connection: connection);
  }

  Future<Map> isMaster({_Connection connection}) {
    return executeDbCommand(DbCommand.createIsMasterCommand(this),
        connection: connection);
  }

  Future<Map> wait() {
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
        DbCommand.createQueryAdminCommand({"listDatabases": 1}));

    var result = [];

    for (var each in commandResult["databases"]) {
      result.add(each["name"]);
    }

    return result;
  }

  Stream<Map> _listCollectionsCursor([Map filter = const {}]) {
    if (this._masterConnection.serverCapabilities.listCollections) {
      return new ListCollectionsCursor(this, filter).stream;
    } else {
      // Using system collections (pre v3.0 API)
      Map selector = {};
      // If we are limiting the access to a specific collection name
      if (filter.containsKey('name')) {
        selector["name"] = "${this.databaseName}.${filter['name']}";
      }
      return new Cursor(
              this,
              new DbCollection(this, DbCommand.SYSTEM_NAMESPACE_COLLECTION),
              selector)
          .stream;
    }
  }

  /// This method uses system collections and therefore do not work on MongoDB v3.0 with and upward
  /// with WiredTiger
  /// Use `getCollectionInfos` instead
  @deprecated
  Stream<Map> collectionsInfoCursor([String collectionName]) {
    return _collectionsInfoCursor(collectionName);
  }

  Stream<Map> _collectionsInfoCursor([String collectionName]) {
    Map selector = {};
    // If we are limiting the access to a specific collection name
    if (collectionName != null) {
      selector["name"] = "${this.databaseName}.$collectionName";
    }
    // Return Cursor
    return new Cursor(
            this,
            new DbCollection(this, DbCommand.SYSTEM_NAMESPACE_COLLECTION),
            selector)
        .stream;
  }

  /// Analogue to shell's `show collections`
  /// This method uses system collections and therefore do not work on MongoDB v3.0 with and upward
  /// with WiredTiger
  /// Use `getCollectionNames` instead
  @deprecated
  Future<List<String>> listCollections() {
    return _collectionsInfoCursor()
        .map((map) => map['name'].split('.'))
        .where((arr) => arr.length == 2)
        .map((arr) => arr.last)
        .toList();
  }

  Future<List<Map>> getCollectionInfos([Map filter = const {}]) {
    return _listCollectionsCursor(filter).toList();
  }

  Future<List<String>> getCollectionNames([Map filter = const {}]) {
    return _listCollectionsCursor(filter).map((map) => map['name']).toList();
  }

  Future<bool> authenticate(String userName, String password,
      {_Connection connection}) async {
    var credential = new UsernamePasswordCredential()
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

    return new Cursor(this,
            new DbCollection(this, DbCommand.SYSTEM_INDEX_COLLECTION), selector)
        .stream
        .toList();
  }

  String _createIndexName(Map keys) {
    var name = '';

    keys.forEach((key, value) {
      name = '${name}_${key}_$value';
    });

    return name;
  }

  Future<Map> createIndex(String collectionName,
      {String key,
      Map keys,
      bool unique,
      bool sparse,
      bool background,
      bool dropDups,
      Map partialFilterExpression,
      String name}) {
    return new Future.sync(() async {
      var selector = {};
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
      if (name == null) {
        name = _createIndexName(keys);
      }
      selector['name'] = name;
      MongoInsertMessage insertMessage = new MongoInsertMessage(
          '$databaseName.${DbCommand.SYSTEM_INDEX_COLLECTION}', [selector]);
      await executeMessage(insertMessage, _writeConcern);
      return getLastError();
    });
  }

  Map _setKeys(String key, Map keys) {
    if (key != null && keys != null) {
      throw new ArgumentError('Only one parameter must be set: key or keys');
    }

    if (key != null) {
      keys = new Map();
      keys['$key'] = 1;
    }

    if (keys == null) {
      throw new ArgumentError('key or keys parameter must be set');
    }

    return keys;
  }

  Future ensureIndex(String collectionName,
      {String key,
      Map keys,
      bool unique,
      bool sparse,
      bool background,
      bool dropDups,
      Map partialFilterExpression,
      String name}) async {
    keys = _setKeys(key, keys);
    var indexInfos = await collection(collectionName).getIndexes();

    if (name == null) {
      name = _createIndexName(keys);
    }

    if (indexInfos.any((info) => info['name'] == name)) {
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

  Future<Map> _getAcknowledgement({WriteConcern writeConcern}) {
    if (writeConcern == null) {
      writeConcern = _writeConcern;
    }

    if (writeConcern == WriteConcern.ERRORS_IGNORED) {
      return new Future.value({'ok': 1.0});
    } else {
      return getLastError(writeConcern);
    }
  }
}
