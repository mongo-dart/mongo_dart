library mongo_actions;

import 'dart:convert' show utf8;
import 'package:universal_io/io.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

const dataPath = '/tmp/mongo_dart-unit_test';
const dataCfg = '$dataPath/configure.js';
const portStd = 27017;
const portBase = 27000;
const rsLength = 3;
const rsName = 'rs';
const mongod = 'mongod';
const mongo = 'mongo';

final _log = Logger('MongoActions');

void _makeEnv([int rsLength = rsLength]) {
  Directory('$dataPath/$portStd').createSync(recursive: true);
  for (var i = 1; i <= rsLength; i++) {
    var port = portBase + i;
    Directory('$dataPath/$port').createSync(recursive: true);
  }
}

//_removeEnv() {
//  new Directory(DATA_PATH).deleteSync(recursive: true);
//}

void _configureRs(StringBuffer buffer, [int rsLength = rsLength]) {
  buffer.write('var x = rs.initiate({');
  buffer.write('"_id": "rs",');
  buffer.write('  "version": 1,');
  buffer.write('  "members": [');
  for (var i = 1; i <= rsLength; i++) {
    buffer.write('    {');
    buffer.write('      "_id": $i,');
    buffer.write('      "host": "localhost:${portBase + i}"');
    buffer.write('    },');
  }
  buffer.write('  ]');
  buffer.write('});');
//  buffer.write('printjson(x);');
}

void _waitRs(StringBuffer buffer) {
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

void _waitDbIsmaster(StringBuffer buffer) {
  buffer.write('x = db.isMaster();');
  buffer.write('printjson(x);');
}

void _initStatus() {
  var script = File(dataCfg);
  var buffer = StringBuffer();
  _waitDbIsmaster(buffer);
  script.writeAsStringSync(buffer.toString());
  //script = null;
}

ProcessResult _startMongod(int port, [String? rs]) {
  _log.info(() => '### Start mongod $port instance');
  var args = [
    '--fork',
    '--smallfiles',
    '--oplogSize',
    '50',
    '--logpath',
    '$dataPath/$port.log',
    '--pidfilepath',
    '$dataPath/$port.pid',
    '--dbpath',
    '$dataPath/$port',
    '--port',
    '$port',
    '-v'
  ];
  if (rs != null) {
    args.addAll(['--replSet', rs]);
  }
  return Process.runSync(mongod, args);
}

void _stopMongod(int port) {
  var pid = _readPidFile('$dataPath/$port.pid');
  if (_checkPid(pid)) {
    _log.info(() => '### Stop mongod $port instance');
    _killPid(pid);
  }
}

void _statusMongod(int port) {
  var pid = _readPidFile('$dataPath/$port.pid');
  if (_checkPid(pid)) {
    var args = ['localhost:$port', dataCfg];
    var result = Process.runSync(mongo, args);
    _log.info(() => '### mongod $port instance is running (PID=$pid)');
    _log.info(() => result.stderr);
    _log.info(() => result.stdout);
  } else {
    _log.info(() => '### mongod $port instance is stopped');
  }
}

void startStandalone() {
  _makeEnv();
  _startMongod(portStd);
}

void stopStandalone() {
  _makeEnv();
  _stopMongod(portStd);
}

void statusStandalone() {
  _initStatus();
  _statusMongod(portStd);
}

void startRs([int rsLength = rsLength]) {
  _makeEnv(rsLength);

  //var futures = new List<Future<Process>>();
  for (var i = 1; i <= rsLength; i++) {
    var port = portBase + i;
    _startMongod(port, rsName);
  }

  var script = File(dataCfg);
  var buffer = StringBuffer();
  _configureRs(buffer, rsLength);
  _waitRs(buffer);
  script.writeAsStringSync(buffer.toString());
  //script = null;

  var port = portBase + 1;
  var args = ['localhost:$port', dataCfg];
  var result = Process.runSync(mongo, args);
  _log.info(() => result.stderr);
  _log.info(() => result.stdout);

  script = File(dataCfg);
  buffer = StringBuffer();
  _waitRs(buffer);
  script.writeAsStringSync(buffer.toString());
  //script = null;

  for (var i = 2; i <= rsLength; i++) {
    var port = portBase + i;
    var args = ['localhost:$port', dataCfg];
    var result = Process.runSync(mongo, args);
    _log.info(() => result.stderr);
    _log.info(() => result.stdout);
  }
}

void stopRs([int rsLength = rsLength]) {
  for (var i = 1; i <= rsLength; i++) {
    _stopMongod(portBase + i);
  }
}

void statusRs([int rsLength = rsLength]) {
  _initStatus();
  for (var i = 1; i <= rsLength; i++) {
    var port = portBase + i;
    _statusMongod(port);
  }
}

int _readPidFile(String path) {
  var file = File(path);
  if (file.existsSync()) {
    var pid = file.readAsStringSync(encoding: utf8).trim();
    return int.parse(pid);
  } else {
    return -1;
  }
}

bool _checkPid(int pid) {
  var process = Process.runSync('ps', ['-p', '$pid']);
  return process.exitCode == 0;
}

bool _killPid(int pid) {
  var process = Process.runSync('kill', ['$pid']);
  return process.exitCode == 0;
}

void main(List<String> args) {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.OFF;
  Logger('MongoActions').level = Level.ALL;

  void listener(LogRecord r) {
    var name = r.loggerName;
    print('${r.time}: $name: ${r.message}');
  }

  Logger.root.onRecord.listen(listener);

  var cmd = (args.isEmpty) ? '' : args[0];
  var topic = (args.length < 2) ? 'all' : args[1];
  switch (cmd) {
    case 'start':
      switch (topic) {
        case 'all':
          stopStandalone();
          startStandalone();
          stopRs();
          startRs();
          break;
        case 'standalone':
          stopStandalone();
          startStandalone();
          break;
        case 'rs':
          stopRs();
          startRs();
          break;
      }
      break;
    case 'stop':
      switch (topic) {
        case 'all':
          stopStandalone();
          stopRs();
          break;
        case 'standalone':
          stopStandalone();
          break;
        case 'rs':
          stopRs();
          break;
      }
      break;
    case 'status':
      switch (topic) {
        case 'all':
          statusStandalone();
          statusRs();
          break;
        case 'standalone':
          statusStandalone();
          break;
        case 'rs':
          statusRs();
          break;
      }
      break;
    default:
      print('Usage: ${basename(Platform.script.path)}'
          '{start|stop|status} [all|standalone|rs]');
  }
}
