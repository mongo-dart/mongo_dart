import 'package:meta/meta.dart';
import 'package:mongo_dart/src/database/document_types.dart';

import '../../core/error/mongo_dart_error.dart';
import '../../mongo_client.dart';
import '../../session/client_session.dart';
import '../../topology/abstract/topology.dart';
import '../../topology/server.dart';

enum Aspect {
  readOperation,
  noInheritOptions,
  writeOperation,
  retryable,
}

typedef Options = Map<String, dynamic>;
typedef Command = Map<String, dynamic>;

abstract class OperationBase {
  Options options;
  final Set<Aspect> _aspects;

  OperationBase(MongoClient mongoClient,
      {Options? options, ClientSession? session, dynamic aspects})
      // Leaves the orgina Options document untouched
      : options = <String, dynamic>{...?options},
        isImplicitSession = session == null,
        _aspects = defineAspects(aspects),
        session = session ?? ClientSession(mongoClient);

  bool isImplicitSession;
  final ClientSession session;

  bool hasAspect(Aspect aspect) => _aspects.contains(aspect);
  MongoClient get mongoClient => session.client;
  Topology get topology =>
      session.client.topology ??
      (throw MongoDartError('Topology not yet identified'));

  //Object? get session => options[keySession];

  // Todo check if this was the meaning of:
  //   Object.assign(this.options, { session });
  /* set session(Object? value) =>
      value == null ? null : options[keySession] = value; */

  //void clearSession() => options.remove(keySession);

  static Set<Aspect> defineAspects(aspects) {
    if (aspects is Aspect) {
      return {aspects};
    } else if (aspects is List<Aspect>) {
      return {...aspects};
    }
    return {Aspect.noInheritOptions};
  }

  bool get canRetryRead => true;

  /// This method is for internal processing
  @protected
  Future<MongoDocument> process();

  @protected
  Future<MongoDocument> executeOnServer(Server server);
}
