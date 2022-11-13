import 'package:logging/logging.dart';

import 'core/error/mongo_dart_error.dart';
import 'topology/abstract/topology.dart';
import 'default_settings.dart';
import 'mongo_client_options.dart';
import 'utils/decode_dns_seed_list.dart';
import 'utils/decode_url_parameters.dart';
import 'utils/split_hosts.dart';
import 'write_concern.dart';
import 'database/db.dart';

typedef ServerApiVersion = Map<String, String>;
const ServerApiVersion serverApiVersion = <String, String>{'v1': '1'};

abstract class ServerApi {
  ServerApi(this.version);

  ServerApiVersion version;
  bool? strict;
  bool? deprecationErrors;
}

abstract class DriverInfo {
  String? name;
  String? version;
  String? platform;
}

class Auth {
  /// The username for auth
  String? username;

  /// The password for auth
  String? password;
}

class MongoClient {
  // This url can be informed both with the Standard
  /// Connection String Format (`mongodb://`) or with the DNS Seedlist
  /// Connection Format (`mongodb+srv://`).
  /// The former has the format:
  /// mongodb://[username:password@]host1[:port1]
  ///      [,...hostN[:portN]][/[defaultauthdb][?options]]
  /// The latter is available from version 3.6. The format is:
  /// mongodb+srv://[username:password@]host1[:port1]
  ///      [/[databaseName][?options]]
  /// More info are available [here](https://docs.mongodb.com/manual/reference/connection-string/)
  MongoClient(this.url, {MongoClientOptions? mongoClientOptions}) {
    this.mongoClientOptions = mongoClientOptions ?? MongoClientOptions();
    var uri = Uri.parse(url);
    if (uri.scheme != 'mongodb' && uri.scheme != 'mongodb+srv') {
      throw MongoDartError(
          'The only valid schemas for Db are: "mongodb" and "mongodb+srv".');
    }
  }

  final Logger log = Logger('Mongo Client');

  String url;
  late MongoClientOptions mongoClientOptions;
  final List<Uri> seedServers = <Uri>[];
  Topology? topology;
  Set activeSessions = {}; // Todo, create the session object
  String defaultDatabaseName = defMongoDbName;
  String defaultAuthDbName = defMongoAuthDbName;

  // ReadConcern
  // Read Preference
  WriteConcern? writeConcern;

  /// Connects to the required server / cluster.
  ///
  /// Steps:
  /// 1) Decode mongodb+srv url if it is the case
  /// 2) Decode the mongodb url
  /// 3) try a connection with the seed list servers
  /// 4) run hello command and determine the topology.
  /// 5) creates the topology.
  Future connect() async {
    var connectionUri = Uri.parse(url);

    var hostsSeedList = <String>[];
    if (connectionUri.scheme == 'mongodb+srv') {
      hostsSeedList.addAll(await decodeDnsSeedlist(connectionUri));
    } else {
      hostsSeedList.addAll(splitHosts(url));
    }
    seedServers.addAll([for (var element in hostsSeedList) Uri.parse(element)]);
    await decodeUrlParameters(connectionUri, mongoClientOptions);
  }

  Future close() async {}

  /// If no name passed, the url specified db is used
  Db db({String? dbName}) =>
      Db.modern(this, dbName ?? mongoClientOptions.defaultDbName);
}