import '../../../mongo_dart_old.dart' show keySession;
import '../../topology/server.dart';

enum Aspect {
  readOperation,
  noInheritOptions,
  writeOperation,
  retryable,
}

abstract class OperationBase {
  Map<String, Object> options;
  final Set<Aspect> _aspects;

  OperationBase(Map<String, Object>? options, {Object? aspects})
      : options = <String, Object>{...?options},
        _aspects = defineAspects(aspects);

  bool hasAspect(Aspect aspect) =>
      /* _aspects != null && */ _aspects.contains(aspect);

  Object? get session => options[keySession];

  // Todo check if this was the meaning of:
  //   Object.assign(this.options, { session });
  set session(Object? value) =>
      value == null ? null : options[keySession] = value;

  void clearSession() => options.remove(keySession);

  bool get canRetryRead => true;

  Future<Map<String, Object?>> execute();

  Future<Map<String, Object?>> executeOnServer(Server server) async =>
      throw UnsupportedError(
          '"execute" must be implemented for OperationBase subclasses');

  static Set<Aspect> defineAspects(aspects) {
    if (aspects is Aspect) {
      return {aspects};
    } else if (aspects is List<Aspect>) {
      return {...aspects};
    }
    return {Aspect.noInheritOptions};
  }
}
