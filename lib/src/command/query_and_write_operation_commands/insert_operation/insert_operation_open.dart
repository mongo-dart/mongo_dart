import 'package:mongo_dart/src/command/query_and_write_operation_commands/insert_operation/insert_options_open.dart';

import 'base/insert_operation.dart';

class InsertOperationOpen extends InsertOperation {
  InsertOperationOpen(super.collection, super.documents,
      {InsertOptionsOpen? insertOptions, super.rawOptions})
      : super.protected(insertOptions: insertOptions);
}
