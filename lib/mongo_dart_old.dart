/// Server-side driver library for MongoDb implemented in pure Dart.
/// As most of IO in Dart, mongo_dart is totally async -using Futures and Streams.
/// .

library mongo_dart;

import 'dart:async';
import 'dart:io' show File, FileMode, IOSink;
import 'dart:typed_data';
import 'package:bson/bson.dart';

import 'package:mongo_dart_query/mongo_dart_query.dart';

import 'src/core/error/mongo_dart_error.dart';

import 'src/database/base/mongo_database.dart';
import 'src/database/base/mongo_collection.dart';

import 'src/core/message/abstract/mongo_message.dart';

export 'package:bson/bson.dart';
export 'package:mongo_dart_query/mongo_aggregation.dart';
export 'package:mongo_dart_query/mongo_dart_query.dart' hide keyQuery;
export 'package:mongo_dart/src/command/command.dart';
export 'package:mongo_dart/src/utils/map_keys.dart';

//part 'src_old/connection_pool.dart';

//part 'src_old/database/cursor/cursor.dart';

//part 'src_old/database/dbcollection.dart';

//part 'src_old/database/dbcommand.dart';

part 'src_old/database/mongo_getmore_message.dart';

part 'src_old/database/mongo_insert_message.dart';

part 'src_old/database/mongo_kill_cursors_message.dart';

part 'src_old/database/mongo_remove_message.dart';

part 'src_old/database/mongo_update_message.dart';

//part 'src/database/state.dart';

part 'src/gridfs/grid_fs_file.dart';

part 'src/gridfs/grid_in.dart';

part 'src/gridfs/grid_out.dart';

part 'src/gridfs/gridfs.dart';

part 'src/gridfs/chunk_handler.dart';
