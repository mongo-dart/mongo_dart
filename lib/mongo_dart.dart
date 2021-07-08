/// Server-side driver library for MongoDb implemented in pure Dart.
/// As most of IO in Dart, mongo_dart is totally async -using Futures and Streams.
/// .

library mongo_dart;

import 'dart:async';
import 'dart:collection';
import 'dart:convert' show base64, utf8;
import 'dart:io'
    show
        File,
        FileMode,
        IOSink,
        SecureSocket,
        SecurityContext,
        Socket,
        TlsException;
import 'dart:math';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:bson/bson.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/src/database/cursor/modern_cursor.dart';
import 'package:mongo_dart/src/database/info/server_status.dart';
import 'package:mongo_dart/src/database/message/additional/section.dart';
import 'package:mongo_dart/src/database/message/mongo_modern_message.dart';
import 'package:mongo_dart/src/database/message/mongo_response_message.dart';
import 'package:mongo_dart/src/database/commands/aggreagation_commands/distinct/distinct_operation.dart';
import 'package:mongo_dart/src/database/commands/aggreagation_commands/distinct/distinct_options.dart';
import 'package:mongo_dart/src/database/commands/aggreagation_commands/distinct/distinct_result.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/update_operation/update_operation.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/update_operation/update_options.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/update_operation/update_statement.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/wrapper/replace_one/replace_one_operation.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/wrapper/replace_one/replace_one_options.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/wrapper/replace_one/replace_one_statement.dart';
import 'package:mongo_dart/src/database/commands/operation.dart';
import 'package:mongo_dart/src/database/utils/dns_lookup.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';
import 'package:mongo_dart/src/database/utils/parms_utils.dart';
import 'package:mongo_dart/src/database/utils/split_hosts.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';
import 'package:pool/pool.dart';

export 'package:bson/bson.dart';
export 'package:mongo_dart_query/mongo_aggregation.dart';
export 'package:mongo_dart_query/mongo_dart_query.dart' hide keyQuery;
export 'package:mongo_dart/src/database/commands/operation.dart';
export 'package:mongo_dart/src/database/utils/map_keys.dart';

part 'src/connection_pool.dart';

part 'src/auth/auth.dart';

part 'src/auth/sasl_authenticator.dart';

part 'src/auth/scram_sha1_authenticator.dart';

part 'src/auth/mongodb_cr_authenticator.dart';

part 'src/database/cursor/cursor.dart';

part 'src/database/db.dart';

part 'src/database/dbcollection.dart';

part 'src/database/dbcommand.dart';

part 'src/database/error.dart';

part 'src/database/mongo_getmore_message.dart';

part 'src/database/mongo_insert_message.dart';

part 'src/database/mongo_kill_cursors_message.dart';

part 'src/database/mongo_message.dart';

part 'src/database/mongo_query_message.dart';

part 'src/database/mongo_remove_message.dart';

part 'src/database/mongo_reply_message.dart';

part 'src/database/mongo_update_message.dart';

part 'src/database/server_config.dart';

part 'src/database/state.dart';

part 'src/gridfs/grid_fs_file.dart';

part 'src/gridfs/grid_in.dart';

part 'src/gridfs/grid_out.dart';

part 'src/gridfs/gridfs.dart';

part 'src/gridfs/chunk_handler.dart';

part 'src/network/connection.dart';

part 'src/network/connection_manager.dart';

part 'src/network/mongo_message_transformer.dart';

part 'src/network/packet_converter.dart';
