import 'package:mongo_dart/src/commands/administration_commands/create_command/create_options.dart';
import 'package:mongo_dart/src/commands/parameters/collation_options.dart';

class CreateViewOptions extends CreateOptions {
  CreateViewOptions({CollationOptions? collation, String? comment})
      : super(collation: collation, comment: comment);
}
