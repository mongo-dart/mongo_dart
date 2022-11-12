import 'auth.dart';
import 'scram_sha1_authenticator.dart';
import 'scram_sha256_authenticator.dart';
import '../error/mongo_dart_error.dart';

AuthenticationScheme selectAuthenticationMechanism(
    String authenticationSchemeName) {
  if (authenticationSchemeName == ScramSha1Authenticator.name) {
    return AuthenticationScheme.SCRAM_SHA_1;
  } else if (authenticationSchemeName == ScramSha256Authenticator.name) {
    return AuthenticationScheme.SCRAM_SHA_256;
  } else {
    throw MongoDartError('Provided authentication scheme is '
        'not supported : $authenticationSchemeName');
  }
}
