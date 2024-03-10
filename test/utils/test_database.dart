import 'package:mongo_dart/mongo_dart.dart';

Future<bool> testDatabase(String uriString) async {
  var db = Db(uriString);
  Uri uri = Uri.parse(uriString);
  try {
    await db.open();
    await db.close();
    return true;
  } on MongoDartError catch (e) {
    if (e.mongoCode == 18) {
      return false;
    }
    rethrow;
  } on Map catch (e) {
    if (e.containsKey(keyCode)) {
      if (e[keyCode] == 18) {
        return false;
      }
    }
    throw StateError('Unknown error $e');
    // When the server is not reachable on the required address (port!?)
  } on ConnectionException catch (e) {
    if (e.message.contains(':${uri.port}')) {
      return false;
    }
    throw StateError('Unknown error $e');
  } catch (e) {
    throw StateError('Unknown error $e');
  }
}

Future<String?> getFcv(String uri) async {
  var db = Db(uri);
  try {
    await db.open();
    var fcv = db.masterConnection.serverCapabilities.fcv;

    await db.close();
    return fcv;
  } on Map catch (e) {
    if (e.containsKey(keyCode)) {
      if (e[keyCode] == 18) {
        return null;
      }
    }
    throw StateError('Unknown error $e');
  } catch (e) {
    throw StateError('Unknown error $e');
  }
}
