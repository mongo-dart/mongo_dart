import 'package:logging/logging.dart';
import 'package:mongo_dart/src/session/session_options.dart';
import 'package:mongo_dart/src/topology/discover.dart';

import 'command/parameters/read_concern.dart';
import 'command/parameters/read_preference.dart';
import 'server_api.dart';
import 'server_side/server_session_pool.dart';
import 'session/client_session.dart';
import 'core/error/mongo_dart_error.dart';
import 'topology/abstract/topology.dart';
import 'settings/default_settings.dart';
import 'mongo_client_options.dart';
import 'utils/decode_dns_seed_list.dart';
import 'utils/decode_url_parameters.dart';
import 'utils/split_hosts.dart';
import 'command/parameters/write_concern.dart';
import 'database/base/mongo_database.dart';

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
    serverSessionPool = ServerSessionPool(this);
  }

  final Logger log = Logger('Mongo Client');

  String url;
  late MongoClientOptions mongoClientOptions;
  final List<Uri> seedServers = <Uri>[];
  Topology? topology;
  String defaultDatabaseName = defMongoDbName;
  String defaultAuthDbName = defMongoAuthDbName;

  late ServerSessionPool serverSessionPool;
  Set<ClientSession> activeSessions = <ClientSession>{};

  DateTime? clientClusterTime;

  WriteConcern? get writeConcern => mongoClientOptions.writeConcern;
  ReadConcern? get readConcern => mongoClientOptions.readConcern;
  ReadPreference? get readPreference => mongoClientOptions.readPreference;

  ServerApi? get serverApi => mongoClientOptions.serverApi;

  Set<MongoDatabase> databases = <MongoDatabase>{};

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

    var discoverTopology = Discover(this, seedServers);

    await discoverTopology.connect();

    topology = await discoverTopology.getEffectiveTopology();
  }

  // TODO clean the serverSessionPool
  Future close() async {}

  /// If no name passed, the url specified db is used
  MongoDatabase db({String? dbName}) {
    dbName ??= mongoClientOptions.defaultDbName;
    try {
      return databases.firstWhere((element) => element.databaseName == dbName);
    } catch (_) {}
    var db = MongoDatabase(this, dbName!);
    databases.add(db);
    return db;
  }

  // Todo
  ClientSession startSession({SessionOptions? clientSessionOptions}) {
    // here also the server session must be assigned
    return ClientSession(this, sessionOptions: clientSessionOptions);
  }
}
