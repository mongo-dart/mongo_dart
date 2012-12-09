library mongo_dart;
import 'dart:isolate';
import 'dart:io';
import 'dart:crypto';
import 'dart:uri';
import 'bson_console.dart';
import 'bson.dart';
import 'src/bson/json_ext.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';


export 'bson_console.dart';
export 'bson.dart';
export 'src/bson/json_ext.dart';

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
part 'src/helpers/map_proxy.dart';
part 'src/helpers/selector_builder.dart';
part 'src/helpers/modifier_builder.dart';
part 'src/gridfs/gridfs.dart';
part 'src/gridfs/grid_file.dart';
part 'src/gridfs/grid_in.dart';
part 'src/gridfs/grid_out.dart';

final Logger _log = Logger.root;

_configureConsoleLogger([Level level = Level.INFO]) {
  _log.level = level;
  _log.on.record.clear();
  _log.on.record.add((LogRecord rec) => print('${rec.time} [${rec.level}] ${rec.message}'));
}