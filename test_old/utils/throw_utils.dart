import 'package:mongo_dart/mongo_dart.dart';
import 'package:test/test.dart' show throwsA;

var throwsMongoDartError = throwsA((e) => e is MongoDartError);
