library hop_runner;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'dart:async';
import 'dart:io';

void main() {

  var paths = ['lib/mongo_dart.dart','example/blog.dart']; //etc etc etc

  addTask('analyze_libs', createAnalyzerTask(paths));

  runHop();
}