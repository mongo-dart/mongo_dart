import 'dart:typed_data';

extension NullableUint8ListExtensions on Uint8List? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
