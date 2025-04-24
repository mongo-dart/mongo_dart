import 'package:mongo_dart/src/database/commands/replication_commands/hello_command/client_metadata.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// Hello command options;
class HelloOptions {
  final String? comment;
  final ClientMetadata clientMetadata;

  const HelloOptions(this.comment, this.clientMetadata);

  Map<String, Object> get options => <String, Object>{
        if (comment != null) keyComment: comment!,
      };
}
