import 'dart:io';
import 'package:path/path.dart' as p;

extension FileExt on File {
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
    File newFile = File(tryPath);
    var count = 1;
    while (await newFile.exists()) {
      tryPath = '$dirname$basename($count)$ext';
      count++;
      newFile = File(tryPath);
    }
    return tryPath;
  }

  Future<File> changeFileNameOnly(String newFileName) async =>
      rename(newPathByName(newFileName));

  Future<File> changeFileNameOnlySafe(String newFileName) async =>
      renameSafe(newPathByName(newFileName));

  Future<File> renameSafe(String newPath) async =>
      rename(await toSafePath(newPath));
}
