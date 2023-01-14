import '../command/base/operation_base.dart';
import '../command/command.dart';
import '../core/error/mongo_dart_error.dart';
import '../mongo_client.dart';
import '../utils/map_keys.dart';

class TransactionOptions {
  /// A default read concern for commands in this transaction */
  ReadConcern? readConcern;

  /// A default writeConcern for commands in this transaction */
  WriteConcern? writeConcern;

  /// A default read preference for commands in this transaction */
  ReadPreference? readPreference;

  /// Specifies the maximum amount of time to allow a commit action on a
  /// transaction to run in milliseconds */
  int? maxCommitTimeMS;

  // TODO manage the vaue depending on the topology
  Options getOptions(MongoClient client) => <String, dynamic>{
        if (writeConcern != null)
          keyWriteConcern: writeConcern!.asMap(
              client.topology?.primary?.serverStatus ??
                  (throw MongoDartError('No server detected'))),
        if (readConcern != null) keyReadConcern: readConcern!.toMap(),
        ...?readPreference?.toMap(),
        if (maxCommitTimeMS != null) keyMaxCommitTimeMS: maxCommitTimeMS
      };
}
