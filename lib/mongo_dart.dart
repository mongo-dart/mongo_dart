library mongo_dart;
import 'dart:isolate';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:collection';
import 'package:bson/bson.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';


export 'package:bson/bson.dart';
export 'package:mongo_dart_query/mongo_dart_query.dart';

part 'src/database/connection.dart';
part 'src/database/mongo_message.dart';
part 'src/database/mongo_query_message.dart';
part 'src/database/mongo_reply_message.dart';
part 'src/database/mongo_insert_message.dart';
part 'src/database/mongo_remove_message.dart';
part 'src/database/mongo_getmore_message.dart';
part 'src/database/mongo_kill_cursors_message.dart';
part 'src/database/mongo_update_message.dart';
part 'src/database/server_config.dart';
part 'src/database/dbcommand.dart';
part 'src/database/db.dart';
part 'src/database/dbcollection.dart';
part 'src/database/cursor.dart';
part 'src/gridfs/gridfs.dart';
part 'src/gridfs/grid_file.dart';
part 'src/gridfs/grid_in.dart';
part 'src/gridfs/grid_out.dart';
part 'src/gridfs/chunk_transformer.dart';

final Logger _log = Logger.root;

_configureConsoleLogger([Level level = Level.INFO]) {
  _log.level = level;
  _log.onRecord.listen((LogRecord rec) => print('${rec.time} [${rec.level}] ${rec.message}'));
}