bool arrayStrictEqual(List arr, List arr2) =>
    mapStrictEqual(arr.asMap(), arr2.asMap());

bool mapStrictEqual(Map mapOne, Map mapTwo) =>
    mapOne.length == mapTwo.length &&
    mapOne.keys.every((key) => mapOne[key] == mapTwo[key]);

bool tagsStrictEqual(Map tags, Map tags2) => mapStrictEqual(tags, tags2);

bool errorStrictEqual(lhs, rhs) {
  if (lhs == rhs) {
    return true;
  }

  if ((lhs == null && rhs != null) || (lhs != null && rhs == null)) {
    return false;
  }

  if (lhs.runtimeType != rhs.runtimeType) {
    return false;
  }

  try {
    if (lhs.message != rhs.message) {
      return false;
    }
  } catch (e) {
    // Do nothing. Not all errors contain the message field
  }

  return true;
}
