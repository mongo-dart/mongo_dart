class ConnectionPoolSettings {
  /// The maximum number of connections in the connection pool.
  int _maxPoolSize = 100;
  int get maxPoolSize => _maxPoolSize;
  set maxPoolSize(int value) {
    if (value >= 0) {
      _maxPoolSize = value;
      if (_maxPoolSize != 0 && _minPoolSize > _maxPoolSize) {
        _minPoolSize = _maxPoolSize;
      }
    }
  }

  /// The minimum number of connections in the connection pool.
  int _minPoolSize = 0;
  int get minPoolSize => _minPoolSize;
  set minPoolSize(int value) {
    if (value >= 0) {
      _maxPoolSize != 0 && _maxPoolSize < value
          ? _minPoolSize = _maxPoolSize
          : _minPoolSize = value;
    }
  }

  /// The maximum number of milliseconds that a connection can remain
  /// idle in the pool before being removed and closed.
  int maxIdleTimeMS = 0;

  /// A number that the driver multiplies the maxPoolSize value to,
  ///  to provide the maximum number of threads allowed to wait for a
  /// connection to become available from the pool.
  /// For default values, see the driver documentation.
  int waitQueueMultiple = 0;

  /// The maximum time in milliseconds that a thread can wait for a
  /// connection to become available.
  int waitQueueTimeoutMS = 0;
}
