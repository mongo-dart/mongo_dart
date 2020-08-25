import 'package:mongo_dart/mongo_dart.dart' show MongoDartError;
import 'package:test/test.dart' show throwsA;

var throwsMongoDartError = throwsA((e) => e is MongoDartError);
