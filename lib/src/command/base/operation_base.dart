import 'package:meta/meta.dart';
import 'package:mongo_dart/src/database/document_types.dart';

import '../../../mongo_dart_old.dart' show keySession;
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

  OperationBase(Options? options, {dynamic aspects})
      // Leaves the orgina Options document untouched
      : options = <String, dynamic>{...?options},
        _aspects = defineAspects(aspects);

  bool hasAspect(Aspect aspect) => _aspects.contains(aspect);

  Object? get session => options[keySession];

  // Todo check if this was the meaning of:
  //   Object.assign(this.options, { session });
  set session(Object? value) =>
      value == null ? null : options[keySession] = value;

  void clearSession() => options.remove(keySession);

  static Set<Aspect> defineAspects(aspects) {
    if (aspects is Aspect) {
      return {aspects};
    } else if (aspects is List<Aspect>) {
      return {...aspects};
    }
    return {Aspect.noInheritOptions};
  }

  bool get canRetryRead => true;
  Future<MongoDocument> execute();

  @protected
  Future<MongoDocument> executeOnServer(Server server);
}
