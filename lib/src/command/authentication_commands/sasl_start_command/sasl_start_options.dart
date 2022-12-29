import 'package:mongo_dart/src/command/base/operation_base.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';

/// SaslStart command options;
class SaslStartOptions {
  /// Undocumented command
  /// Fields inferred from MongoDbDriver
  /// [see also:](https://github.com/mongodb/specifications/blob/master/source/auth/auth.rst)
  final bool skipEmptyExchange;
  final int autoAuthorize;

  const SaslStartOptions(
      {this.skipEmptyExchange = true, this.autoAuthorize = 1});

  Options get options => <String, dynamic>{
        keyOptions: {keySkipEmptyExchange: skipEmptyExchange},
        keyAutoAuthorize: 1
      };
}
