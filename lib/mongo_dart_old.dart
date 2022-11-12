/// Server-side driver library for MongoDb implemented in pure Dart.
/// As most of IO in Dart, mongo_dart is totally async -using Futures and Streams.
/// .

library mongo_dart;

import 'dart:async';
import 'dart:collection';
import 'dart:convert' show base64;
import 'dart:io' show File, FileMode, IOSink;
import 'dart:typed_data';
import 'package:bson/bson.dart';
import 'package:mongo_dart/src/core/network/abstract/connection_base.dart';
import 'package:mongo_dart/src_old/database/cursor/modern_cursor.dart';
import 'package:mongo_dart/src_old/database/commands/aggregation_commands/distinct/distinct_operation.dart';
import 'package:mongo_dart/src_old/database/commands/aggregation_commands/distinct/distinct_options.dart';
import 'package:mongo_dart/src_old/database/commands/aggregation_commands/distinct/distinct_result.dart';
import 'package:mongo_dart/src_old/database/commands/query_and_write_operation_commands/update_operation/update_operation.dart';
import 'package:mongo_dart/src_old/database/commands/query_and_write_operation_commands/update_operation/update_options.dart';
import 'package:mongo_dart/src_old/database/commands/query_and_write_operation_commands/update_operation/update_statement.dart';
import 'package:mongo_dart/src_old/database/commands/operation.dart';
import 'package:mongo_dart/src/utils/map_keys.dart';
import 'package:mongo_dart/src_old/database/utils/parms_utils.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';
import 'package:pool/pool.dart';

import 'src/core/error/mongo_dart_error.dart';
import 'src/core/message/deprecated/mongo_query_message.dart';
import 'src/core/message/deprecated/mongo_reply_message.dart';
import 'src/core/topology/server.dart';
import 'src/write_concern.dart';
import 'src_old/database/commands/administration_commands/drop_indexes_command/drop_indexes_command.dart';
import 'src_old/database/commands/administration_commands/drop_indexes_command/drop_indexes_options.dart';
import 'src_old/database/commands/administration_commands/listt_indexes_command/list_indexes_command.dart';
import 'src_old/database/commands/administration_commands/listt_indexes_command/list_indexes_options.dart';
import 'src_old/database/commands/aggregation_commands/count/count_operation.dart';
import 'src_old/database/commands/aggregation_commands/count/count_options.dart';
import 'src_old/database/commands/aggregation_commands/count/count_result.dart';
import 'src/core/message/abstract/mongo_message.dart';

export 'package:bson/bson.dart';
export 'package:mongo_dart_query/mongo_aggregation.dart';
export 'package:mongo_dart_query/mongo_dart_query.dart' hide keyQuery;
export 'package:mongo_dart/src_old/database/commands/operation.dart';
export 'package:mongo_dart/src/utils/map_keys.dart';

part 'src_old/connection_pool.dart';

part 'src_old/database/cursor/cursor.dart';

part 'src_old/database/dbcollection.dart';

part 'src_old/database/dbcommand.dart';

part 'src_old/database/mongo_getmore_message.dart';

part 'src_old/database/mongo_insert_message.dart';

part 'src_old/database/mongo_kill_cursors_message.dart';

part 'src_old/database/mongo_remove_message.dart';

part 'src_old/database/mongo_update_message.dart';

part 'src_old/database/state.dart';

part 'src_old/gridfs/grid_fs_file.dart';

part 'src_old/gridfs/grid_in.dart';

part 'src_old/gridfs/grid_out.dart';

part 'src_old/gridfs/gridfs.dart';

part 'src_old/gridfs/chunk_handler.dart';
