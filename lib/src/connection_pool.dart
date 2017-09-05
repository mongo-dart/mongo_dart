part of mongo_dart;

/// A function that produces an instance of [Db], whether synchronously or asynchronously.
///
/// This is used in the [ConnectionPool] class to connect to a database on-the-fly.
typedef FutureOr<Db> _DbFactory();

/// A connection pool that limits the number of concurrent connections to a MongoDB server.
///
/// The connection pool lazily connects to the database; that is to say, it only opens as many
/// connections as it needs to. If it is only ever called once, then it will only ever connect once.
class ConnectionPool {
  List<Db> _connections = [];
  int _index = 0;
  Pool _pool;

  /// The maximum number of concurrent connections allowed.
  final int maxConnections;

  /// A [_DbFactory], a parameterless function that returns a [Db]. The function can be asynchronous if necessary.
  final _DbFactory dbFactory;

  /// Initializes a connection pool.
  ///
  /// * `maxConnections`: The maximum amount of connections to keep open simultaneously.
  /// * `dbFactory*: a parameterless function that returns a [Db]. The function can be asynchronous if necessary.
  ConnectionPool(this.maxConnections, this.dbFactory) {
    _pool = new Pool(maxConnections);
  }

  /// Connects to the database, using an existent connection, only creating a new one if
  /// the number of active connections is less than [maxConnections].
  Future<Db> connect() {
    return _pool.withResource<Db>(() async {
      int i = _index;
      if (_index >= maxConnections) _index = 0;

      if (i < _connections.length)
        return _connections[i];
      else {
        var db = await dbFactory();
        await db.open();
        _connections.add(db);
        return db;
      }
    });
  }

  /// Closes all active database connections.
  Future close() {
    return Future
        .wait(_connections.map<Future>((c) => c.close()))
        .then((_) => _pool.close());
  }
}
