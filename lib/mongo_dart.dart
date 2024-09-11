/// Server-side driver library for MongoDb implemented in pure Dart.
/// As most of IO in Dart, mongo_dart is totally async -using Futures and Streams.
/// .

library mongo_dart;

import 'dart:async';
import 'dart:collection';
import 'dart:convert' show base64;
import 'dart:math';
import 'dart:typed_data';
import 'package:universal_io/io.dart'
    show
        File,
        FileMode,
        IOSink,
        Platform,
        SecureSocket,
        SecurityContext,
        Socket,
        TlsException;

import 'package:bson/bson.dart';
// ignore: implementation_imports
import 'package:bson/src/types/bson_map.dart';
// ignore: implementation_imports
import 'package:bson/src/types/bson_string.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import 'package:mongo_dart/src/auth/scram_sha256_authenticator.dart';
import 'package:mongo_dart/src/database/cursor/modern_cursor.dart';
import 'package:mongo_dart/src/database/info/server_status.dart';
import 'package:mongo_dart/src/database/message/additional/section.dart';
import 'package:mongo_dart/src/database/message/mongo_modern_message.dart';
import 'package:mongo_dart/src/database/message/mongo_response_message.dart';
import 'package:mongo_dart/src/database/commands/aggregation_commands/distinct/distinct_operation.dart';
import 'package:mongo_dart/src/database/commands/aggregation_commands/distinct/distinct_options.dart';
import 'package:mongo_dart/src/database/commands/aggregation_commands/distinct/distinct_result.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/update_operation/update_operation.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/update_operation/update_options.dart';
import 'package:mongo_dart/src/database/commands/query_and_write_operation_commands/update_operation/update_statement.dart';
import 'package:mongo_dart/src/database/commands/operation.dart';
import 'package:mongo_dart/src/database/utils/dns_lookup.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';
import 'package:mongo_dart/src/database/utils/parms_utils.dart';
import 'package:mongo_dart/src/database/utils/split_hosts.dart';
import 'package:mongo_dart/src/extensions/file_ext.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';
import 'package:pool/pool.dart';
import 'package:mongo_dart/src/auth/auth.dart'
    show Authenticator, AuthenticationScheme;
import 'package:mongo_dart/src/auth/scram_sha1_authenticator.dart'
    show ScramSha1Authenticator;
import 'package:mongo_dart/src/auth/scram_sha256_authenticator.dart'
    show ScramSha256Authenticator;
import 'package:mongo_dart/src/auth/mongodb_cr_authenticator.dart'
    show MongoDbCRAuthenticator;
import 'package:sasl_scram/sasl_scram.dart' show UsernamePasswordCredential;
import 'package:vy_string_utils/vy_string_utils.dart';

import 'src/auth/x509_authenticator.dart';
import 'src/database/commands/administration_commands/drop_command/drop_command.dart';
import 'src/database/commands/administration_commands/drop_command/drop_options.dart';
import 'src/database/commands/administration_commands/drop_database_command/drop_database_command.dart';
import 'src/database/commands/administration_commands/drop_database_command/drop_database_options.dart';
import 'src/database/commands/administration_commands/drop_indexes_command/drop_indexes_command.dart';
import 'src/database/commands/administration_commands/drop_indexes_command/drop_indexes_options.dart';
import 'src/database/commands/administration_commands/list_collections_command/list_collections_command.dart';
import 'src/database/commands/administration_commands/list_collections_command/list_collections_options.dart';
import 'src/database/commands/administration_commands/listt_indexes_command/list_indexes_command.dart';
import 'src/database/commands/administration_commands/listt_indexes_command/list_indexes_options.dart';
import 'src/database/commands/aggregation_commands/aggregate/return_classes/change_event.dart';
import 'src/database/commands/aggregation_commands/count/count_operation.dart';
import 'src/database/commands/aggregation_commands/count/count_options.dart';
import 'src/database/commands/aggregation_commands/count/count_result.dart';
import 'src/database/commands/base/command_operation.dart';
import 'src/database/commands/base/db_admin_command_operation.dart';
import 'src/database/commands/diagnostic_commands/ping_command/ping_command.dart';
import 'package:path/path.dart' as p;

export 'package:bson/bson.dart';
export 'package:mongo_dart_query/mongo_aggregation.dart';
export 'package:mongo_dart_query/mongo_dart_query.dart' hide keyQuery;
export 'package:mongo_dart/src/database/commands/operation.dart';
export 'package:mongo_dart/src/database/utils/map_keys.dart';

part 'src/connection_pool.dart';

//part 'src/auth/auth.dart';
//part 'src/auth/sasl_authenticator.dart';
//part 'src/auth/scram_sha1_authenticator.dart';
//part 'src/auth/mongodb_cr_authenticator.dart';

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
