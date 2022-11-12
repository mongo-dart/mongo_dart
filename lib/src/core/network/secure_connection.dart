import 'dart:async';

import 'package:mongo_dart/src/core/network/abstract/connection_base.dart';
import 'package:universal_io/io.dart';

import '../error/connection_exception.dart';
import '../info/server_config.dart';

class SecureConnection extends ConnectionBase {
  static bool _caCertificateAlreadyInHash = false;

  SecureConnection(ServerConfig serverConfig) : super.protected(serverConfig);

  @override
  Future<void> connect() async {
    Socket locSocket;
    try {
      var securityContext = SecurityContext.defaultContext;
      if (serverConfig.tlsCAFileContent != null &&
          !_caCertificateAlreadyInHash) {
        securityContext
            .setTrustedCertificatesBytes(serverConfig.tlsCAFileContent!);
      }
      if (serverConfig.tlsCertificateKeyFileContent != null) {
        securityContext
          ..useCertificateChainBytes(serverConfig.tlsCertificateKeyFileContent!)
          ..usePrivateKeyBytes(serverConfig.tlsCertificateKeyFileContent!,
              password: serverConfig.tlsCertificateKeyFilePassword);
      }

      locSocket = await SecureSocket.connect(
          serverConfig.host, serverConfig.port, context: securityContext,
          onBadCertificate: (certificate) {
        // couldn't find here if the cause is an hostname mismatch
        return serverConfig.tlsAllowInvalidCertificates;
      });
    } on TlsException catch (e) {
      if (e.osError?.message
              .contains('CERT_ALREADY_IN_HASH_TABLE(x509_lu.c:356)') ??
          false) {
        _caCertificateAlreadyInHash = true;
        return connect();
      }
      var ex = ConnectionException(
          'Could not connect to ${serverConfig.hostUrl}\n- $e');
      throw ex;
    } catch (e) {
      var ex = ConnectionException(
          'Could not connect to ${serverConfig.hostUrl}\n- $e');
      throw ex;
    }

    setSocket(locSocket);
  }
}
