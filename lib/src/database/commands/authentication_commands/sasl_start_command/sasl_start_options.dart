import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// SaslStart command options;
class SaslStartOptions {
  /// Undocumented command
  /// Fields inferred from MongoDbDriver
  /// [see also:](https://github.com/mongodb/specifications/blob/master/source/auth/auth.rst)
  final bool skipEmptyExchange;
  final int autoAuthorize;

  const SaslStartOptions(
      {this.skipEmptyExchange = true, this.autoAuthorize = 1});

  Map<String, Object> get options => <String, Object>{
        keyOptions: {keySkipEmptyExchange: skipEmptyExchange},
        keyAutoAuthorize: 1
      };
}
