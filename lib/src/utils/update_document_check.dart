/// This method returns true if all the top keys are update operators
/// (start with "$").
/// If the document is null or empty returns false;
/// It is used to check the update document in operations like updateOne()
@Deprecated('Use UpdateSpec getter instead')
bool containsOnlyUpdateOperators(Map<String, dynamic> updateDocument) =>
    updateDocument.isNotEmpty &&
    updateDocument.keys
            .firstWhere((element) => element[0] != r'$', orElse: () => r'$') ==
        r'$';

/// This method returns true if none of the top keys are update operators
/// (start with "$").
/// If the document is null or empty returns false;
/// It is used to check the replace document in operations like replaceOne()
@Deprecated('Use UpdateSpec getter instead')
bool isPureDocument(Map<String, dynamic> updateDocument) =>
    updateDocument.isNotEmpty &&
    updateDocument.keys
            .firstWhere((element) => element[0] == r'$', orElse: () => '#') ==
        '#';
