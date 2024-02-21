// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:io';
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:mongo_dart/src/extensions/byte_ext.dart';
import 'package:path/path.dart' as p;

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
