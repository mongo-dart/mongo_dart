@Timeout(Duration(minutes: 1))
library;

import 'dart:io' show Platform;
import 'package:mongo_dart/src/version.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/src/database/commands/replication_commands/hello_command/client_metadata.dart';
import 'package:test/test.dart';

void main() async {
  group('ClientMetadata', () {
    group('#options', () {
      var application = ApplicationMetadata('mongo_dart app');
      var clientMetadata = ClientMetadata(application);
      var options = clientMetadata.options;
      var client = options[keyClient] as Map<String, Object>;

      test('it returns an application name', () {
        expect((client[keyApplication] as Map<String, Object>)[keyName],
            'mongo_dart app');
      });

      test('it returns driver information', () {
        expect(
            (client[keyDriver] as Map<String, Object>)[keyName], mongoDartName);
        expect((client[keyDriver] as Map<String, Object>)[keyVersion],
            mongoDartVersion);
      });

      test('it returns os information', () {
        expect((client[keyOs] as Map<String, Object>)[keyType],
            Platform.operatingSystem);
      });

      test('it returns platform imformation', () {
        expect(client[keyPlatform], 'dart ${Platform.version}');
      });
    });
  });

  group('ApplicationMetadata', () {
    group('when the string is under 128 bytes', () {
      var appName = 'Application';
      var application = ApplicationMetadata(appName);

      test('it does not truncate the string', () {
        expect(application.name, appName);
      });
    });

    group('when the string is over 128 bytes', () {
      var longString = '€' * 150;
      var application = ApplicationMetadata(longString);

      test('it truncates the string to 128 bytes', () {
        expect(application.name.length, 128);
      });
    });
  });
}
