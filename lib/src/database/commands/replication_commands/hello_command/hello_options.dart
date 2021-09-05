import 'package:mongo_dart/src/database/utils/map_keys.dart';

/// Hello command options;
class HelloOptions {
  final String? comment;

  const HelloOptions({this.comment});

  Map<String, Object> get options => <String, Object>{
        if (comment != null) keyComment: comment!,
      };
}
