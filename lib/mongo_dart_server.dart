// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#library("mongo_dart_server");
#import("dart:io");
#import("dart:isolate");
#import("src/mongo_dart_server/mongo_dart_server_impl.dart");
#import("../packages/args/args.dart");

const DEFAULT_PORT = 8123;
const DEFAULT_HOST = "127.0.0.1";

void main() {
  // For profiling stopping after some time is convenient. Set
  // stopAfter for that.
  int stopAfter;
  var parser = new ArgParser();
  parser.addOption('uri', abbr: 'u', defaultsTo: 'mongodb://127.0.0.1/mongo_dart_server_test', help: "Uri for MongoDb database to connect");
  parser.addOption('port', abbr: 'p', defaultsTo: '8123', help: "Port for mongo_dart_server");
  parser.addFlag('help',abbr: 'h', negatable: false);
  var args = parser.parse(new Options().arguments);
  if (args["help"] == true) {
    print(parser.getUsage());
    return;
  }
  var serverPort = spawnFunction(startMongoDartServer);
  ServerMain serverMain =
      new ServerMain.start(serverPort, DEFAULT_HOST, DEFAULT_PORT);

  // Start a shutdown timer if requested.
  if (stopAfter != null) {
    new Timer(stopAfter * 1000, (timer) => serverMain.shutdown());
  }
}
