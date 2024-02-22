// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:io';
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:mongo_dart/src/extensions/byte_ext.dart';
import 'package:path/path.dart' as p;

class XFileMode {
  /// The mode for opening a file only for reading.
  static const read = XFileMode._internal(0);

  /// Mode for opening a file for reading and writing. The file is
  /// overwritten if it already exists. The file is created if it does not
  /// already exist.
  static const write = XFileMode._internal(1);

  /// Mode for opening a file for reading and writing to the
  /// end of it. The file is created if it does not already exist.
  static const append = XFileMode._internal(2);

  /// Mode for opening a file for writing *only*. The file is
  /// overwritten if it already exists. The file is created if it does not
  /// already exist.
  static const writeOnly = XFileMode._internal(3);

  /// Mode for opening a file for writing *only* to the
  /// end of it. The file is created if it does not already exist.
  static const writeOnlyAppend = XFileMode._internal(4);

  final int mode;

  const XFileMode._internal(this.mode);
}

extension FileExt on XFile {
  String get name =>
      path.substring(path.lastIndexOf(Platform.pathSeparator) + 1);

  String newPathByName(String newFileName) =>
      path.substring(0, path.lastIndexOf(Platform.pathSeparator) + 1) +
      newFileName;

  Future<String> get safePath async => toSafePath(path);

  Future<String> toSafePath(String newPath) async {
    var basename = p.basenameWithoutExtension(newPath);
    var dirname = p.dirname(newPath) + Platform.pathSeparator;
    var ext = p.extension(newPath);

    String tryPath = newPath;
    XFile newFile = XFile(tryPath);
    var count = 1;
    while (await newFile.exists()) {
      tryPath = '$dirname$basename($count)$ext';
      count++;
      newFile = XFile(tryPath);
    }
    return tryPath;
  }

  Future<XFile> changeFileNameOnly(String newFileName) async => copyWith(
        path: newPathByName(newFileName),
        name: newFileName,
      );

  Future<XFile> changeFileNameOnlySafe(String newFileName) async =>
      renameSafe(newPathByName(newFileName));

  Future<XFile> renameSafe(String newPath) async => copyWith(
        path: await toSafePath(newPath),
      );

  Future<bool> exists() async => (await readAsBytes()).isNotNullOrEmpty;

  copyWith({
    String? path,
    String? mimeType,
    String? name,
    int? length,
    Uint8List? bytes,
    DateTime? lastModified,
  }) async =>
      XFile(
        path ?? this.path,
        mimeType: mimeType ?? this.mimeType,
        name: name ?? this.name,
        length: length ?? await this.length(),
        bytes: bytes ?? await readAsBytes(),
        lastModified: lastModified ?? await this.lastModified(),
      );
}
