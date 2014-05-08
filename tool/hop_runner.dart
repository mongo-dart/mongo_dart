library hop_runner;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:hop_docgen/hop_docgen.dart';

void main(args) {

  var paths = ['lib/mongo_dart.dart','example/blog.dart']; //etc etc etc

  addTask('analyze_libs', createAnalyzerTask(paths));

 addTask('docs',  createDocGenTask(r'..\dartdoc-viewer'));

  runHop(args);
}