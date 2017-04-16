library dart_pad.grind;

import 'package:grinder/grinder.dart';

main(List args) => grind(args);

@DefaultTask()
@Task()
analyze() {
  new PubApp.global('tuneup')..run(['check']);
}
