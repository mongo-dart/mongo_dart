import 'package:mongo_dart/src/utils/union_type.dart';

const W wMajority = W('majority');
const W primaryAcknowledged = W(1);

/// The String value can be 'majority' or a customo defined
/// write concern base on servers tags (settings.getLastErrorModes)
/// defined through replica set settings. In detail:
///   Type: document
///    A document used to define a custom write concern through the use of members[n].tags. The custom write concern can provide data-center awareness.
///    { getLastErrorModes: {
///       <name of write concern> : { <tag1>: <number>, .... },
///       ...
///    } }
///
/// The <number> refers to the number of different tag values required to
///   satisfy the write concern. For example, the following
/// settings.getLastErrorModes defines a write concern named datacenter
/// that requires the write to propagate to two members whose dc tag values
/// differ.
///
/// { getLastErrorModes: { datacenter: { "dc": 2 } } }
/// To use the custom write concern, pass in the write concern name
///   to the w Option, e.g.
/// { w: "datacenter" }
/// See Configure Replica Set Tag Sets for more information and example.

class W extends UnionType<int, String> {
  const W(super.value);
}
