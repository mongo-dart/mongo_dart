library hop_runner;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

void main(args) {

  var paths = ['lib/mongo_dart.dart','example/blog.dart']; //etc etc etc

  addTask('analyze_libs', createAnalyzerTask(paths));

//  addTask('docs',createDartDocTask(['lib/mongo_dart.dart'], linkApi: true, excludeLibs: ['fixnum']));

  runHop(args);
}