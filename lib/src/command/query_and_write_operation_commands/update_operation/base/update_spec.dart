import 'package:mongo_dart/mongo_dart.dart';

import '../../../../unions/base/union_type.dart';

class UpdateSpec extends UnionType<MongoDocument, List<UpdateDocument>> {
  UpdateSpec(super.value) {
    if (isNull) {
      throw MongoDartError('The update|pipeline document cannot be null');
    }
  }

  /// This method returns true if none of the top keys are update operators
  /// (start with "$").
  /// If the document is null or empty returns false;
  /// Pipeline returns false
  /// It is used to check the replace document in operations like replaceOne()
  bool get isPureDocument {
    if (isNull || valueTwo != null) {
      return false;
    }
    return valueOne!.keys
            .firstWhere((element) => element[0] == r'$', orElse: () => '#') ==
        '#';
  }

  /// This method returns true if all the top keys are update operators
  /// (start with "$").
  /// If the document is null or empty returns false;
  /// It is used to check the update document in operations like updateOne()
  bool get containsOnlyUpdateOperators {
    if (isNull) {
      return false;
    }
    if (valueOne != null) {
      return valueOne!.isNotEmpty &&
          valueOne!.keys.firstWhere((element) => element[0] != r'$',
                  orElse: () => r'$') ==
              r'$';
    }
    // pipeline
    if (valueTwo!.isEmpty) {
      return false;
    }
    for (var element in valueTwo!) {
      var ret = element.keys.firstWhere((element) => element[0] != r'$',
              orElse: () => r'$') ==
          r'$';
      if (!ret) {
        return false;
      }
    }
    return true;
  }
}
