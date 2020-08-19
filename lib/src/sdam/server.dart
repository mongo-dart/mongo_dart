// Todo to be completed

import 'package:mongo_dart/src/sdam/server_description.dart';

const skeyDescription = 'description';
// Todo, used in common.dart, check if it is really set
const skeyServerDescription = 'serverDescription';
const skeyOptions = 'options';
const skeyTopology = 'topology';

class Server {
  Map<String, dynamic> s;

  Server(ServerDescription description, Map options, topology) {
    s = <String, dynamic>{
      skeyDescription: description,
      skeyOptions: options,
      skeyTopology: topology
    };
  }

  ServerDescription get description =>
      s[skeyDescription] ?? s[skeyServerDescription];
}
