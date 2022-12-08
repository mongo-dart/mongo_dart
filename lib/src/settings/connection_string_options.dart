/// Connection String Options
/// This section lists all connection options.
/// Connection options are pairs in the following form: name=value.
///     The option name is case insensitive when using a driver.
///     The option name is case insensitive when using mongosh
///     The value is always case sensitive.
/// Separate options with the ampersand (i.e. &) character
///   name1=value1&name2=value2. In the following example, a connection
/// includes the replicaSet and connectTimeoutMS options:
///
///  mongodb://db1.example.net:27017,db2.example.net:2500/?replicaSet=test&connectTimeoutMS=300000

class ConnectionStringOptions {
  // *Replica Set Option*

  /// The following connection string to a replica set named myRepl with members
  /// running on the specified hosts:
  ///
  ///  mongodb://db0.example.com:27017,db1.example.com:27017,db2.example.com:27017/?replicaSet=myRepl

  /// Specifies the name of the replica set, if the mongod is a member of a
  /// replica set.
  /// When connecting to a replica set, provide a seed list of the replica
  /// set member(s) to the host[:port] component of the uri.
  static const replicaSet = 'replicaSet';

  // *TLS Options*

  /// Enables or disables TLS/SSL for the connection:
  ///  true: Initiate the connection with TLS/SSL.
  ///    Default for DNS Seed List Connection Format.
  ///  false: Initiate the connection without TLS/SSL.
  ///    Default for Standard Connection String Format.
  ///  *Note*
  /// The tls option is equivalent to the ssl option.
  static const tls = 'tls';
  static const ssl = 'ssl';

  /// Specifies the location of a local .pem file that contains either
  ///   the client's TLS/SSL X.509 certificate or the client's TLS/SSL
  ///   certificate and key.
  /// The client presents this file to the mongodmongos instance.
  /// Changed in version 4.4: mongod / mongos logs a warning on connection
  ///   if the presented x.509 certificate expires within 30 days of the
  ///   mongod/mongos host system time. See x.509 Certificates
  ///   Nearing Expiry Trigger Warnings for more information.
  static const tlsCertificateKeyFile = 'tlsCertificateKeyFile';

  /// Specifies the password to de-crypt the tlsCertificateKeyFile
  static const tlsCertificateKeyFilePassword = 'tlsCertificateKeyFilePassword';

  /// Specifies the location of a local .pem file that contains the
  ///  root certificate chain from the Certificate Authority.
  /// This file is used to validate the certificate presented by the
  /// mongod/mongos instance.
  static const tlsCAFile = 'tlsCAFile';

  /// Bypasses validation of the certificates presented by the
  ///   mongod/mongos instance
  /// Set to true to connect to MongoDB instances even if the
  ///   server's present invalid certificates.
  /// ***Warning*** Disabling certificate validation creates a vulnerability.
  static const tlsAllowInvalidCertificates = 'tlsAllowInvalidCertificates';

  /// Disables hostname validation of the certificate presented by the
  ///   mongod/mongos instance.
  /// Set to true to connect to MongoDB instances even if the hostname
  ///   in the server certificates do not match the server's host.
  /// ***Warning*** Disabling certificate validation creates a vulnerability.
  /// *********    NOT YET MANAGED     *******************
  static const tlsAllowInvalidHostnames = 'tlsAllowInvalidHostnames';

  /// Disables various certificate validations.
  ///   Set to true to disable certificate validations.
  /// The exact validatations disabled vary by drivers. Refer to the
  ///   Drivers documentation.
  /// ***Warning*** Disabling certificate validation creates a vulnerability.
  /// *********    NOT YET MANAGED     *******************
  static const tlsInsecure = 'tlsInsecure';

  // *Timeout Options*

  /// The time in milliseconds to attempt a connection before timing out.
  /// The default is 10,000 milliseconds
  /// *********    NOT YET MANAGED     *******************
  static const connectTimeoutMS = 'connectTimeoutMS';

  /// The time in milliseconds to attempt a send or receive on a socket
  ///   before the attempt times out. The default is never to timeout
  /// *********    NOT YET MANAGED     *******************
  static const socketTimeoutMS = 'socketTimeoutMS';

  // *Compression Options*
  /// Comma-delimited string of compressors to enable network compression
  /// for communication between this client and a mongodmongos instance.
  /// You can specify the following compressors:
  /// - snappy
  /// - zlib (Available in MongoDB 3.6 or greater)
  /// - zstd (Available in MongoDB 4.2 or greater)
  /// If you specify multiple compressors, then the order in which you list
  ///   the compressors matter as well as the communication initiator.
  /// For example, if the client specifies the following network compressors
  ///   "zlib,snappy" and the mongod specifies "snappy,zlib", messages between
  ///   the client and the mongod uses zlib.
  /// *Important* Messages are compressed when both parties enable network
  ///   compression. Otherwise, messages between the parties are uncompressed.
  /// If the parties do not share at least one common compressor,
  ///   messages between the parties are uncompressed.
  /// *********    NOT YET MANAGED     *******************
  static const compressors = 'compressors';

  ///   An integer that specifies the compression level if using zlib for network compression
  ///  You can specify an integer value ranging from -1 to 9:
  ///  Value    Notes
  ///   -1      Default compression level, usually level 6 compression.
  ///    0      No compression
  ///    1 - 9  Increasing level of compression but at the cost of speed, with:
  ///         1 providing the best speed but least compression, and
  ///         9 providing the best compression but at the slowest speed.
  /// *********    NOT YET MANAGED     *******************
  static const zlibCompressionLevel = 'zlibCompressionLevel';

  // *Connection Pool Options*

  /// The maximum number of connections in the connection pool.
  ///   The default value is 100.
  static const maxPoolSize = 'maxPoolSize';

  /// The minimum number of connections in the connection pool.
  /// The default value is 0.
  static const minPoolSize = 'minPoolSize';

  /// The maximum number of milliseconds that a connection can remain
  /// idle in the pool before being removed and closed.
  /// *********    NOT YET MANAGED     *******************
  static const maxIdleTimeMS = 'maxIdleTimeMS';

  /// A number that the driver multiplies the maxPoolSize value to,
  ///   to provide the maximum number of threads allowed to wait for
  ///   a connection to become available from the pool
  /// *********    NOT YET MANAGED     *******************
  static const waitQueueMultiple = 'waitQueueMultiple';

  /// The maximum time in milliseconds that a thread can wait for a
  ///   connection to become available.
  /// *********    NOT YET MANAGED     *******************
  static const waitQueueTimeoutMS = 'waitQueueTimeoutMS';

  // *Write Concern Options*

  /// Corresponds to the write concern w Option.
  /// The w option requests acknowledgement that the write operation has
  /// propagated to a specified number of mongod instances or to mongod
  /// instances with specified tags. You can specify a number,
  /// the string majority, or a tag set
  /// *********    NOT YET MANAGED     *******************
  static const w = 'w';

  /// Corresponds to the write concern wtimeout. wtimeoutMS specifies a time
  /// limit, in milliseconds, for the write concern.
  /// When wtimeoutMS is 0, write operations will never time out.
  /// *********    NOT YET MANAGED     *******************
  static const wtimeoutMS = 'wtimeoutMS';

  /// Corresponds to the write concern j Option option.
  /// The journal option requests acknowledgement from MongoDB that
  /// the write operation has been written to the journal.
  /// For details, see j Option.
  /// If you set journal to true, and specify a w value less than 1,
  /// journal prevails.
  /// If you set journal to true, and the mongod does not have
  /// journaling enabled, as with storage.journal.enabled, then MongoDB
  /// will error.
  /// *********    NOT YET MANAGED     *******************
  static const journal = 'journal';

  // *readConcern Options*

  /// The level of isolation. Can accept one of the following values:
  /// - local
  /// - majority
  /// - linearizable
  /// - available
  ///
  /// Specify the read concern as an option to the specific operation.
  /// *********    NOT YET MANAGED     *******************
  static const readConcernLevel = 'readConcernLevel';

  // *Read Preference Options*

  /// Specifies the read preferences for this connection. Possible values are:
  /// - primary (Default)
  /// - primaryPreferred
  /// - secondary
  /// - secondaryPreferred
  /// - nearest
  /// Multi-document transactions that contain read operations must use
  /// read preference primary. All operations in a given transaction
  /// must route to the same member.
  /// *********    NOT YET MANAGED     *******************
  static const readPreference = 'readPreference';

  /// Specifies, in seconds, how stale a secondary can be before the client
  /// stops using it for read operations. For details,
  /// see Read Preference maxStalenessSeconds
  /// By default, there is no maximum staleness and clients will not consider
  /// a secondary's lag when choosing where to direct a read operation.
  /// The minimum maxStalenessSeconds value is 90 seconds.
  /// Specifying a value between 0 and 90 seconds will produce an error.
  /// MongoDB drivers treat a maxStalenessSeconds value of -1 as "no max
  /// staleness", the same as if maxStalenessSeconds is omitted.
  /// *********    NOT YET MANAGED     *******************
  static const maxStalenessSeconds = 'maxStalenessSeconds';

  /// Specifies the tags document as a comma-separated list of
  /// colon-separated key-value pairs. For example,
  /// - To specify the tags document { "dc": "ny", "rack": "r1" },
  ///   use readPreferenceTags=dc:ny,rack:r1 in the connection string.
  /// - To specify an empty tags document { },
  ///   use readPreferenceTags= without setting the value.
  /// To specify a list of tag documents, use multiple readPreferenceTags.
  /// For example, readPreferenceTags=dc:ny,rack:r1&readPreferenceTags=.
  /// Order matters when using multiple readPreferenceTags.
  /// The readPreferenceTags are tried in order until a match is found.
  /// For details, see Order of Tag Matching.
  /// *********    NOT YET MANAGED     *******************
  static const readPreferenceTags = 'readPreferenceTags';

  // *Authentication  Options*

  /// Specify the database name associated with the user's credentials.
  /// If authSource is unspecified, authSource defaults to the defaultauthdb
  /// specified in the connection string. If defaultauthdb is unspecified,
  /// then authSource defaults to admin.
  /// The PLAIN (LDAP), GSSAPI (Kerberos), and MONGODB-AWS (IAM)
  /// authentication mechanisms require that authSource be set to $external,
  /// as these mechanisms delegate credential storage to external services.
  /// MongoDB will ignore authSource values if no username is provided,
  static const authSource = 'authSource';

  /// Specify the authentication mechanism that MongoDB will use to
  /// authenticate the connection. Possible values include:
  ///  - SCRAM-SHA-1
  ///  - SCRAM-SHA-256 (Added in MongoDB 4.0)
  ///  - MONGODB-X509
  ///  - MONGODB-AWS (Added in MongoDB 4.4)
  ///  - GSSAPI (Kerberos)
  ///  - PLAIN (LDAP SASL)
  /// MongoDB 4.0 removes support for the MONGODB-CR authentication mechanism.
  ///  You cannot specify MONGODB-CR as the authentication mechanism
  /// when connecting to MongoDB 4.0+ deployments.
  /// Only MongoDB Enterprise mongod and mongos instances provide GSSAPI
  /// (Kerberos) and PLAIN (LDAP) mechanisms.
  /// To use MONGODB-X509, you must have TLS/SSL Enabled.
  /// To use MONGODB-AWS, you must be connecting to a MongoDB Atlas cluster
  /// which has been configured to support authentication via AWS IAM
  /// credentials (i.e. an AWS access key ID and a secret access key,
  /// and optionally an AWS session token).
  /// The MONGODB-AWS authentication mechanism requires that the authSource
  /// be set to $external.
  /// When using MONGODB-AWS, provide your AWS access key ID as the username
  /// and the secret access key as the password. If using an AWS session token
  /// as well, provide it with the AWS_SESSION_TOKEN authMechanismProperties
  /// value.
  /// *Note*
  /// If the AWS access key ID, secret access key, or session token include
  /// the following characters:
  /// : / ? # [ ] @
  /// those characters must be converted using percent encoding.
  /// Alternatively, if the AWS access key ID, secret access key,
  /// or session token are defined on your platform using their respective
  /// AWS IAM environment variables
  /// mongosh will use these environment variable values to authenticate;
  /// you do not need to specify them in the connection string.
  /// See Connect to an Atlas Cluster for example usage of the
  /// MONGODB-AWS authentication mechanism using both a connection string
  /// and the environment variables method.
  /// See Authentication for more information about the authentication
  /// system in MongoDB. Also consider Use x.509 Certificates to
  /// Authenticate Clients for more information on x509 authentication.
  static const authMechanism = 'authMechanism';

  /// Specify properties for the specified authMechanism as a comma-separated list of colon-separated key-value pairs.
  /// Possible key-value pairs are:
  /// - SERVICE_NAME:<string>
  ///     Set the Kerberos service name when connecting to Kerberized MongoDB
  ///     instances. This value must match the service name set on MongoDB
  ///     instances to which you are connecting. Only valid when using the
  ///     GSSAPI authentication mechanism.
  ///
  ///     SERVICE_NAME defaults to mongodb for all clients and MongoDB instances.
  ///     If you change the saslServiceName setting on a MongoDB instance,
  ///     you must set SERVICE_NAME to match that setting. Only valid when
  ///     using the GSSAPI authentication mechanism.
  ///
  /// - CANONICALIZE_HOST_NAME:true|false
  ///     Canonicalize the hostname of the client host machine when connecting
  ///     to the Kerberos server. This may be required when hosts report
  ///     different hostnames than what is in the Kerberos database.
  ///     Defaults to false. Only valid when using the GSSAPI authentication
  ///     mechanism.
  ///
  /// - SERVICE_REALM:<string>
  ///     Set the Kerberos realm for the MongoDB service. This may be necessary
  ///     to support cross-realm authentication where the user exists in one
  ///     realm and the service in another. Only valid when using the GSSAPI
  ///     authentication mechanism.
  ///
  /// - AWS_SESSION_TOKEN:<security_token>
  ///     Set the AWS session token for authentication with temporary
  ///     credentials when using an AssumeRole request, or when working
  ///     with AWS resources that specify this value such as Lambda.
  ///     Only valid when using the MONGODB-AWS authentication mechanism.
  ///     You must have an AWS access key ID and a secret access key as well.
  ///     See Connect to an Atlas Cluster for example usage.
  /// *********    NOT YET MANAGED     *******************
  static const authMechanismProperties = 'authMechanismProperties';

  ///  Set the Kerberos service name when connecting to Kerberized MongoDB
  /// instances. This value must match the service name set on MongoDB
  /// instances to which you are connecting.
  /// gssapiServiceName defaults to mongodb for all clients and MongoDB
  /// instances. If you change saslServiceName setting on a MongoDB instance,
  /// you must set gssapiServiceName to match that setting.
  /// gssapiServiceName is a deprecated aliases for
  /// authMechanismProperties=SERVICE_NAME:mongodb.
  /// *********    NOT YET MANAGED     *******************
  static const gssapiServiceName = 'gssapiServiceName';

  // *Server Selection and Discovery Options*

  /// The size (in milliseconds) of the latency window for selecting among
  /// multiple suitable MongoDB instances. Default: 15 milliseconds.
  /// All drivers use localThresholdMS. Use the localThreshold alias when
  /// specifying the latency window size to mongos
  /// *********    NOT YET MANAGED     *******************
  static const localThresholdMS = 'localThresholdMS';

  /// Specifies how long (in milliseconds) to block for server selection
  /// before throwing an exception. Default: 30,000 milliseconds.
  /// *********    NOT YET MANAGED     *******************
  static const serverSelectionTimeoutMS = 'serverSelectionTimeoutMS';

  /// Single-threaded drivers only. When true, instructs the driver to
  /// scan the MongoDB deployment exactly once after server selection
  /// fails and then either select a server or raise an error. When false,
  /// the driver blocks and searches for a server up to the
  /// serverSelectionTimeoutMS value. Default: true.
  /// Multi-threaded drivers and mongos do not support serverSelectionTryOnce
  /// *********    NOT YET MANAGED     *******************
  static const serverSelectionTryOnce = 'serverSelectionTryOnce';

  /// heartbeatFrequencyMS controls when the driver checks the state of the MongoDB deployment. Specify the interval (in milliseconds) between checks, counted from the end of the previous check until the beginning of the next one.
  /// Default:
  /// - Single-threaded drivers: 60 seconds.
  /// - Multi-threaded drivers: 10 seconds.
  /// mongos does not support changing the frequency of the heartbeat checks.
  /// *********    NOT YET MANAGED     *******************
  static const heartbeatFrequencyMS = 'heartbeatFrequencyMS';

  // *Miscellaneous Configuration*

  /// Specify a custom app name. The app name appears in:
  /// - mongod and mongoslogs
  /// - the currentOp.appName field in the currentOp command and db.currentOp() method output
  /// - the system.profile.appName field in the database profiler output
  /// *********    NOT YET MANAGED     *******************
  static const appName = 'appName';

  /// Enables retryable reads.
  /// Possible values are:
  /// - true. Enables retryable reads for the connection.
  ///   Official MongoDB drivers compatible with MongoDB Server 4.2 and
  ///   later default to true.
  /// - false. Disables retryable reads for the connection.
  /// *********    NOT YET MANAGED     *******************
  static const retryReads = 'retryReads';

  /// Enable retryable writes.
  /// Possible values are:
  /// - true. Enables retryable writes for the connection.
  ///     Official MongoDB 4.2+ compatible drivers default to true.
  /// - false. Disables retryable writes for the connection.
  ///     Official MongoDB 4.0 and 3.6-compatible drivers default to false.
  /// MongoDB drivers retry transaction commit and abort operations
  /// regardless of the value of retryWrites. For more information on
  /// transaction retryability, see Transaction Error Handling.
  /// *********    NOT YET MANAGED     *******************
  static const retryWrites = 'retryWrites';

  /// Possible values are:
  /// - standard
  ///     The standard binary representation.
  /// - csharpLegacy
  ///     The default representation for the C# driver.
  /// - javaLegacy
  ///     The default representation for the Java driver.
  /// - pythonLegacy
  ///     The default representation for the Python driver.
  ///
  /// For the default, see the Drivers documentation for your driver.
  /// *********    NOT YET MANAGED     *******************
  static const uuidRepresentation = 'uuidRepresentation';
}
