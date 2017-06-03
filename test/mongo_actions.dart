library mongo_actions;

import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

const DATA_PATH = "/tmp/mongo_dart-unit_test";
const DATA_CFG = "$DATA_PATH/configure.js";
const PORT_STD = 27017;
const PORT_BASE = 27000;
const RS_LENGTH = 3;
const RS_NAME = "rs";
const MONGOD = "mongod";
const MONGO = "mongo";

final _log = new Logger('MongoActions');

_makeEnv([int rsLength = RS_LENGTH]) {
  new Directory("$DATA_PATH/$PORT_STD").createSync(recursive: true);
  for (var i = 1; i <= rsLength; i++) {
    var port = PORT_BASE + i;
    new Directory("$DATA_PATH/$port").createSync(recursive: true);
  }
}

//_removeEnv() {
//  new Directory(DATA_PATH).deleteSync(recursive: true);
//}

_configureRs(StringBuffer buffer, [int rsLength = RS_LENGTH]) {
  buffer.write('var x = rs.initiate({');
  buffer.write('"_id": "rs",');
  buffer.write('  "version": 1,');
  buffer.write('  "members": [');
  for (var i = 1; i <= rsLength; i++) {
    buffer.write('    {');
    buffer.write('      "_id": $i,');
    buffer.write('      "host": "localhost:${PORT_BASE + i}"');
    buffer.write('    },');
  }
  buffer.write('  ]');
  buffer.write('});');
//  buffer.write('printjson(x);');
}

_waitRs(StringBuffer buffer) {
  buffer.write('print("Waiting for instance to initiate");');
  buffer.write('while(1) {');
  buffer.write('  sleep(2000);');
  buffer.write('  x = db.isMaster();');
//  buffer.write('  printjson(x);');
  buffer.write('  if (x.ismaster || x.secondary) {');
  buffer.write('    print("Instance is online now");');
  buffer.write('    break;');
  buffer.write('  }');
  buffer.write('}');
}

_waitDbIsmaster(StringBuffer buffer) {
  buffer.write('x = db.isMaster();');
  buffer.write('printjson(x);');
}

_initStatus() {
  var script = new File(DATA_CFG);
  var buffer = new StringBuffer();
  _waitDbIsmaster(buffer);
  script.writeAsStringSync(buffer.toString());
  script = null;
}

ProcessResult _startMongod(int port, [String rs]) {
  _log.info(() => "### Start mongod $port instance");
  var args = [
    "--fork",
    "--smallfiles",
    "--oplogSize",
    "50",
    "--logpath",
    "$DATA_PATH/$port.log",
    "--pidfilepath",
    "$DATA_PATH/$port.pid",
    "--dbpath",
    "$DATA_PATH/$port",
    "--port",
    "$port",
    "-v"
  ];
  if (rs != null) {
    args.addAll(["--replSet", rs]);
  }
  return Process.runSync(MONGOD, args);
}

_stopMongod(int port) {
  var pid = _readPidFile("$DATA_PATH/$port.pid");
  if (_checkPid(pid)) {
    _log.info(() => "### Stop mongod $port instance");
    _killPid(pid);
  }
}

_statusMongod(int port) {
  var pid = _readPidFile("$DATA_PATH/$port.pid");
  if (_checkPid(pid)) {
    var args = ["localhost:$port", DATA_CFG];
    var result = Process.runSync(MONGO, args);
    _log.info(() => "### mongod $port instance is running (PID=$pid)");
    _log.info(() => result.stderr);
    _log.info(() => result.stdout);
  } else {
    _log.info(() => "### mongod $port instance is stopped");
  }
}

startStandalone() {
  _makeEnv();
  _startMongod(PORT_STD);
}

stopStandalone() {
  _makeEnv();
  _stopMongod(PORT_STD);
}

statusStandalone() {
  _initStatus();
  _statusMongod(PORT_STD);
}

startRs([int rsLength = RS_LENGTH]) {
  _makeEnv(rsLength);

  //var futures = new List<Future<Process>>();
  for (var i = 1; i <= rsLength; i++) {
    var port = PORT_BASE + i;
    _startMongod(port, RS_NAME);
  }

  var script = new File(DATA_CFG);
  var buffer = new StringBuffer();
  _configureRs(buffer, rsLength);
  _waitRs(buffer);
  script.writeAsStringSync(buffer.toString());
  script = null;

  var port = PORT_BASE + 1;
  var args = ["localhost:$port", DATA_CFG];
  var result = Process.runSync(MONGO, args);
  _log.info(() => result.stderr);
  _log.info(() => result.stdout);

  script = new File(DATA_CFG);
  buffer = new StringBuffer();
  _waitRs(buffer);
  script.writeAsStringSync(buffer.toString());
  script = null;

  for (var i = 2; i <= rsLength; i++) {
    var port = PORT_BASE + i;
    var args = ["localhost:$port", DATA_CFG];
    var result = Process.runSync(MONGO, args);
    _log.info(() => result.stderr);
    _log.info(() => result.stdout);
  }
}

stopRs([int rsLength = RS_LENGTH]) {
  for (var i = 1; i <= rsLength; i++) {
    _stopMongod(PORT_BASE + i);
  }
}

statusRs([int rsLength = RS_LENGTH]) {
  _initStatus();
  for (var i = 1; i <= rsLength; i++) {
    var port = PORT_BASE + i;
    _statusMongod(port);
  }
}

int _readPidFile(String path) {
  var file = new File(path);
  if (file.existsSync()) {
    var pid = file.readAsStringSync(encoding: UTF8).trim();
    return int.parse(pid);
  } else {
    return -1;
  }
}

bool _checkPid(int pid) {
  var process = Process.runSync("ps", ["-p", "$pid"]);
  return process.exitCode == 0;
}

bool _killPid(int pid) {
  var process = Process.runSync("kill", ["$pid"]);
  return process.exitCode == 0;
}

void main(List<String> args) {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.OFF;
  new Logger('MongoActions').level = Level.ALL;
  var listener = (LogRecord r) {
    var name = r.loggerName;
    print("${r.time}: $name: ${r.message}");
  };
  Logger.root.onRecord.listen(listener);

  var cmd = (args.length < 1) ? "" : args[0];
  var topic = (args.length < 2) ? "all" : args[1];
  switch (cmd) {
    case "start":
      switch (topic) {
        case "all":
          stopStandalone();
          startStandalone();
          stopRs();
          startRs();
          break;
        case "standalone":
          stopStandalone();
          startStandalone();
          break;
        case "rs":
          stopRs();
          startRs();
          break;
      }
      break;
    case "stop":
      switch (topic) {
        case "all":
          stopStandalone();
          stopRs();
          break;
        case "standalone":
          stopStandalone();
          break;
        case "rs":
          stopRs();
          break;
      }
      break;
    case "status":
      switch (topic) {
        case "all":
          statusStandalone();
          statusRs();
          break;
        case "standalone":
          statusStandalone();
          break;
        case "rs":
          statusRs();
          break;
      }
      break;
    default:
      print("Usage: " +
          basename(Platform.script.path) +
          "{start|stop|status} [all|standalone|rs]");
  }
}
