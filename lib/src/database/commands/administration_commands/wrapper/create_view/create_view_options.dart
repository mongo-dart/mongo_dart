import 'package:mongo_dart/src/database/commands/administration_commands/create_command/create_options.dart';

class CreateViewOptions extends CreateOptions {
  CreateViewOptions({super.collation, super.comment});
}
