import 'package:ghpages_generator/ghpages_generator.dart' as gh;

main() {
  new gh.Generator()
  ..setDartDoc(['lib/mongo_dart.dart'], excludedLibs: ['path'])
  ..generate();
}