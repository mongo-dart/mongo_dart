import 'package:mongo_dart/src/settings/connection_pool_settings.dart';

import 'commands/parameters/read_concern.dart';
import 'commands/parameters/read_preference.dart';
import 'core/auth/auth.dart';
import 'core/compression.dart';
import 'mongo_client.dart';

/// Describes all possible URI query options for the mongo client
/// @public
/// @see https://docs.mongodb.com/manual/reference/connection-string
class MongoClientOptions
    with
        ConnectionPoolSettings /*extends BSONSerializeOptions,  SupportedNodeConnectionOptions*/ {
  /// Specifies the name of the replica set, if the mongod is a member of a
  /// replica set.
  String? replicaSet;

  /// Enables or disables TLS/SSL for the connection.
  bool tls = false;

  /// A boolean to enable or disables TLS/SSL for the connection.
  /// (The ssl option is equivalent to the tls option.) */
  set ssl(bool value) => tls = value;

  /// Specifies the location of a local TLS Certificate */
  String? tlsCertificateFile;

  /// Specifies the location of a local .pem file that contains either
  /// the client's TLS/SSL certificate and key or only the client's TLS/SSL key
  /// when tlsCertificateFile is used to provide the certificate. */
  String? tlsCertificateKeyFile;

  /// Specifies the password to de-crypt the tlsCertificateKeyFile. */
  String? tlsCertificateKeyFilePassword;

  /// Specifies the location of a local .pem file that contains the
  /// root certificate chain from the Certificate Authority.
  /// This file is used to validate the certificate presented by the
  /// mongod/mongos instance. */
  String? tlsCAFile;

  /// Bypasses validation of the certificates presented by the mongod/mongos instance */
  bool tlsAllowInvalidCertificates = false;

  /// Disables hostname validation of the certificate presented by the
  /// mongod/mongos instance. */
  bool? tlsAllowInvalidHostnames;

  /// Disables various certificate validations.
  bool? tlsInsecure;

  /// The time in milliseconds to attempt a connection before timing out.
  int? connectTimeoutMS;

  /// The time in milliseconds to attempt a send or receive on a socket
  /// before the attempt times out.
  int? socketTimeoutMS;

  /// An array or comma-delimited string of compressors to enable network
  /// compression for communication between this client and a mongod/mongos
  /// instance.
  List<CompressorName>? compressors;
  set compressorsString(String value) => compressors ??= [
        for (var compressor in value.split(','))
          CompressorName.values
              .toList()
              .firstWhere((element) => element.name == compressor)
      ];

  /// An integer that specifies the compression level if using zlib
  /// for network compression.
  /// From 0 to 9 or null
  int? zlibCompressionLevel;

  /// The maximum number of hosts to connect to when using an srv connection
  /// string, a setting of `0` means unlimited hosts
  int? srvMaxHosts;

  /// Modifies the srv URI to look like:
  ///
  /// `_{srvServiceName}._tcp.{hostname}.{domainname}`
  ///
  /// Querying this DNS URI is expected to respond with SRV records
  String? srvServiceName;

  /// Specify a read concern for the collection (only MongoDB 3.2 or
  /// higher supported)
  // Todo ReadConcernLike? readConcern;
  /// The level of isolation */
  ReadConcernLevel? readConcernLevel;

  /// Specifies the read preferences for this connection
  ReadPreference? readPreference;

  /// Specifies, in seconds, how stale a secondary can be before the client
  /// stops using it for read operations. Inside ReadPreference Object
  //int? maxStalenessSeconds;

  /// Specifies the tags document as a comma-separated list of colon-separated
  /// key-value pairs. Inside ReadPreference Object
  // List<TagSet>? readPreferenceTags;

  /// Specify the default database name for connection.
  String? defaultDbName;

  /// The auth settings for when connection to server.
  Auth? auth;

  /// Specify the database name associated with the user’s credentials.
  String? authSource;

  /// Specify the authentication mechanism that MongoDB will use to
  /// authenticate the connection.
  AuthenticationScheme? authenticationMechanism =
      AuthenticationScheme.SCRAM_SHA_1;

  /// Specify properties for the specified authMechanism as a comma-separated
  /// list of colon-separated key-value pairs.
  // Todo AuthMechanismProperties? authMechanismProperties;
  /// The size (in milliseconds) of the latency window for selecting among
  /// multiple suitable MongoDB instances.
  int? localThresholdMS;

  /// Specifies how long (in milliseconds) to block for server selection
  /// before throwing an exception.
  int? serverSelectionTimeoutMS;

  /// heartbeatFrequencyMS controls when the driver checks the state of the
  /// MongoDB deployment. Specify the interval (in milliseconds) between checks,
  /// counted from the end of the previous check until the beginning
  /// of the next one.
  int? heartbeatFrequencyMS;

  /// Sets the minimum heartbeat frequency. In the event that the driver
  /// has to frequently re-check a server's availability, it will wait at
  /// least this long since the previous check to avoid wasted effort.
  int? minHeartbeatFrequencyMS;

  /// The name of the application that created this MongoClient instance.
  /// MongoDB 3.4 and newer will print this value in the server log upon
  /// establishing each connection. It is also recorded in the slow query
  /// log and profile collections
  String? appName;

  /// Enables retryable reads.
  bool? retryReads;

  /// Enable retryable writes.
  bool? retryWrites;

  /// Allow a driver to force a Single topology type with a connection
  /// string containing one host
  bool? directConnection;

  /// Instruct the driver it is connecting to a load balancer fronting a
  /// mongos like service
  bool? loadBalanced;

  /// The write concern w value
  // Todo W? w;
  /// The write concern timeout
  int? wtimeoutMS;

  /// The journal write concern
  bool? journal;

  /// Validate mongod server certificate against Certificate Authority
  bool? sslValidate;

  /// SSL Certificate file path.
  String? sslCA;

  /// SSL Certificate file path.
  String? sslCert;

  /// SSL Key file file path.
  String? sslKey;

  /// SSL Certificate pass phrase
  String? sslPass;

  /// SSL Certificate revocation list file path.
  String? sslCRL;

  /// TCP Connection no delay
  bool? noDelay;

  /// TCP Connection keep alive enabled
  bool? keepAlive;

  /// The number of milliseconds to wait before initiating keepAlive
  /// on the TCP socket
  int? keepAliveInitialDelay;

  /// Force server to assign `_id` values instead of driver
  bool? forceServerObjectId;

  /// Return document results as raw BSON buffers
  bool? raw;

  /// A primary key factory function for generation of custom `_id` keys
  // Todo PkFactory? pkFactory;
  /// A Promise library class the application wishes to use such as Bluebird,
  /// must be ES6 compatible
  dynamic promiseLibrary;

  /// The logging level
  // Todo LoggerLevel? loggerLevel;
  /// Custom logger object
  // Todo Logger? logger;
  /// Enable command monitoring for this client
  bool? monitorCommands;

  /// Server API version
  // Todo serverApi?: ServerApi | ServerApiVersion;
  /// Optionally enable client side auto encryption
  ///
  /// @remarks
  ///  Automatic encryption is an enterprise only feature that only applies
  /// to operations on a collection. Automatic encryption is not supported
  /// for operations on a database or view, and operations that are not
  /// bypassed will result in error
  ///  (see [libmongocrypt: Auto Encryption Allow-List](https://github.com/mongodb/specifications/blob/master/source/client-side-encryption/client-side-encryption.rst#libmongocrypt-auto-encryption-allow-list)). To bypass automatic encryption for all operations, set bypassAutoEncryption=true in AutoEncryptionOpts.
  ///
  ///  Automatic encryption requires the authenticated user to have
  /// the [listCollections privilege action](https://docs.mongodb.com/manual/reference/command/listCollections/#dbcmd.listCollections).
  ///
  ///  If a MongoClient with a limited connection pool size
  /// (i.e a non-zero maxPoolSize) is configured with AutoEncryptionOptions,
  /// a separate internal MongoClient is created if any of the following are
  /// true:
  ///  - AutoEncryptionOptions.keyVaultClient is not passed.
  ///  - AutoEncryptionOptions.bypassAutomaticEncryption is false.
  ///
  /// If an internal MongoClient is created, it is configured with the same
  /// options as the parent MongoClient except minPoolSize is set to 0 and
  /// AutoEncryptionOptions is omitted.
  // Todo AutoEncryptionOptions?  autoEncryption;
  /// Allows a wrapping driver to amend the client metadata generated by
  /// the driver to include information about the wrapping driver */
  DriverInfo? driverInfo;

  /// Configures a Socks5 proxy host used for creating TCP connections.
  String? proxyHost;

  /// Configures a Socks5 proxy port used for creating TCP connections.
  int? proxyPort;

  /// Configures a Socks5 proxy username when the proxy in proxyHost requires
  /// username/password authentication.
  String? proxyUsername;

  /// Configures a Socks5 proxy password when the proxy in proxyHost
  /// requires username/password authentication.
  String? proxyPassword;
}
