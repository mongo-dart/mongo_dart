extension StringExtensions on String {
  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => !isBlank;
}

extension NullableStringExtensions on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
  bool get isNotNullOrBlank => !isNullOrBlank;
}
