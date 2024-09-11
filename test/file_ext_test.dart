import 'package:universal_io/io.dart';

import 'package:mongo_dart/src/extensions/file_ext.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  var dir = Directory(current);
  var filename = Uuid().v4();
  var file = File('${dir.path}${Platform.pathSeparator}$filename');
  await file.writeAsString('Test');
  group('Base methods', () {
    test('Name', () {
      expect(file.name, filename);
    });
    test('New Path by Name', () {
      expect(file.newPathByName('prova'),
          '${dir.path}${Platform.pathSeparator}prova');
    });
    test('Safe Path', () async {
      var newPath = await file.safePath;
      expect(newPath, '${dir.path}${Platform.pathSeparator}$filename(1)');
    });
    test('To Safe Path', () async {
      var newPath = await file.toSafePath(file.newPathByName('prova'));
      expect(newPath, '${dir.path}${Platform.pathSeparator}prova');
    });
  });

  group('Change File Name', () {
    test('Change File Name Only', () async {
      var changedFile = await file.copy(file.newPathByName('chgf'));
      var newFile = await changedFile.changeFileNameOnly('testo');
      var name = newFile.name;
      await newFile.delete();
      expect(name, 'testo');
    });

    test('Change File Name Only - two tries', () async {
      var changedFile = await file.copy(file.newPathByName('chgf2'));
      await changedFile.changeFileNameOnly('test2');
      changedFile = await file.copy(file.newPathByName('chgf2'));
      var newFile2 = await changedFile.changeFileNameOnly('test2');
      var name = newFile2.name;
      var exists = await changedFile.exists();
      var exists2 = await newFile2.exists();

      await newFile2.delete();
      expect(name, 'test2');
      expect(exists, isFalse);
      expect(exists2, isTrue);
    });
  });
  group('Safe Change File Name', () {
    test('Safe Change File Name Only', () async {
      var changedFile = await file.copy(file.newPathByName('chgf4'));
      var newFile = await changedFile.changeFileNameOnlySafe('test4.ts');
      var name = newFile.name;
      await newFile.delete();
      expect(name, 'test4.ts');
    });

    test('Change File Name Only - two tries', () async {
      var changedFile = await file.copy(file.newPathByName('chgf3'));
      var newFile = await changedFile.changeFileNameOnlySafe('test3.1.ts');
      changedFile = await file.copy(file.newPathByName('chgf3'));
      var newFile2 = await changedFile.changeFileNameOnlySafe('test3.1.ts');
      var name = newFile.name;
      var name2 = newFile2.name;

      var exists = await changedFile.exists();
      var exists2 = await newFile.exists();
      var exists3 = await newFile2.exists();

      await newFile.delete();
      await newFile2.delete();

      expect(name, 'test3.1.ts');
      expect(name2, 'test3.1(1).ts');

      expect(exists, isFalse);
      expect(exists2, isTrue);
      expect(exists3, isTrue);
    });
  });

  tearDownAll(() async {
    await file.delete();
  });
}
