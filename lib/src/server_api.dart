import 'package:mongo_dart/mongo_dart.dart'
    show keyApiStrict, keyApiVersion, keyApiDeprecationErrors;

import 'command/base/operation_base.dart' show Options;
import 'server_api_version.dart';

class ServerApi {
  const ServerApi(this.version, {this.strict, this.deprecationErrors});

  final ServerApiVersion version;
  final bool? strict;
  final bool? deprecationErrors;

  /// If an API version was declared, drivers MUST add the apiVersion option
  /// to every command that is sent to a server.
  /// Drivers MUST add the apiStrict and apiDeprecationErrors options if
  /// they were specified by the user, even when the specified value is equal
  /// to the server default.
  /// Drivers MUST NOT add any API versioning options if the user did not
  /// specify them.
  /// This includes the getMore command as well as all commands that are part
  /// of a transaction.
  /// A previous version of this specification excluded those commands,
  /// but that has since changed in the server.
  Options get options => <String, dynamic>{
        keyApiVersion: version.version,
        if (strict != null) keyApiStrict: strict,
        if (deprecationErrors != null)
          keyApiDeprecationErrors: deprecationErrors
      };
}
