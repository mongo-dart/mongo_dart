import 'abstract/topology.dart';

/// This is a class used uniquely to discover which is the
/// topology of our connection.
/// It tries to connect on each seed server until it is able to
/// discover the topology.
/// Once that it is done it can build the correct object.
/// Here the connection is made only on one server.
/// The correct topology object will have to complete all the connections.
class Discover extends Topology {
  Discover(super.hostsSeedList, super.mongoClientOptions) : super.protected();
}
