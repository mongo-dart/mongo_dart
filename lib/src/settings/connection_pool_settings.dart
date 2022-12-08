class ConnectionPoolSettings {
  /// The maximum number of connections in the connection pool.
  int maxPoolSize = 100;

  /// The minimum number of connections in the connection pool.
  int minPoolSize = 0;

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
