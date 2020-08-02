import 'package:mongo_dart/mongo_dart.dart'
    show BsonBinary, MongoDartError, MongoMessage;
import 'package:mongo_dart/src/database/message/additional/section.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'mongo_response_message.dart';

const int notFound = -1;

class MongoModernMessage extends MongoResponseMessage {
  static const int basePayloadType = 0;
  static const int documentsPayloadType = 1;

  // Maybe that this is not necessary, but i create small sections if needed.
  // It is not clear in the documentation why we can have more than one section
  // of type 1. I assumed that is because of the size.
  // If this assumption is wrong, please remove this logic.
  static const int maxDocumentsPerPayload1 = 50;

  /// Checksum present
  static const int flagCheckSumPresent = 1;

  /// The OP_MSG message is essentially a request-response protocol,
  /// one message per turn.
  /// However, setting the moreToCome flag indicates to the recipient that
  /// the sender is not ready to give up its turn and will send another message.
  /// On Requests
  /// When the moreToCome flag is set on a request it signals to the recipient
  /// that the sender does not want to know the outcome of the message.
  /// There is no response to a request where moreToCome has been set.
  /// Clients doing unacknowledged writes MUST set the moreToCome flag,
  /// and MUST set the writeConcern to w=0.
  /// If, during the processing of a moreToCome flagged write request,
  /// a server discovers that it is no longer primary, then the server
  /// will close the connection.
  /// All other errors during processing will be silently dropped,
  /// and will not result in the connection being closed.
  /// On Responses
  /// When the moreToCome flag is set on a response it signals to the recipient
  /// that the sender will send additional responses on the connection.
  /// The recipient MUST continue to read responses until it reads a response
  /// with the moreToCome flag not set, and MUST NOT send any more requests
  /// on this connection until it reads a response with the moreToCome
  /// flag not set.
  /// The client MUST either consume all messages with the moreToCome flag
  /// set or close the connection.
  /// When the server sends responses with the moreToCome flag set,
  /// each of these responses will have a unique messageId, and the responseTo
  /// field of every follow-up response will be the messageId of
  /// the previous response.
  /// The client MUST be prepared to receive a response without moreToCome
  /// set prior to completing iteration of a cursor, even if an earlier
  /// response for the same cursor had the moreToCome flag set.
  /// To continue iterating such a cursor, the client MUST issue an
  /// explicit getMore request.
  static const int flagMoreToCome = 2;

  /// Setting this flag on a request indicates to the recipient that the sender
  /// is prepared to handle multiple replies (using the moreToCome bit) to this
  /// request. The server will never produce replies with the moreToCome bit set
  /// unless the request has the exhaustAllowed bit set.
  /// Setting the exhaustAllowed bit on a request does not guarantee that
  /// the responses will have the moreToCome bit set.
  /// MongoDB server only handles the exhaustAllowed bit on the following
  /// operations. A driver MUST NOT set the exhaustAllowed bit on other
  /// operations.
  /// Operation 	Minimum MongoDB Version
  ///   getMore 	        4.2
  static const int flagExhaustAllowed = 65536;

  // commandName and commandArgument must be synchronized, i.e.
  // name and argument must have the same index in the respective lists.
  // if a command has no arguments, the entry in the commandArguments list
  // will be null;
  static List<String> commandName = <String>[
    keyCreateIndexes,
    keyInsert,
    keyUpdate,
    keyDelete,
    keyServerStatus
  ];
  static List<String> commandArgument = <String>[
    keyCreateIndexesArgument,
    keyInsertArgument,
    keyUpdateArgument,
    keyDeleteArgument,
    null
  ];
  static List<String> globalArgument = <String>[
    keyDatabaseName,
    keyReadPreference
  ];

  /// Certain commands support "pulling out" arguments from the command,
  /// and providing them as Payload Type 1, where the identifier is the
  /// command argument’s name.
  /// Specifying a command argument as a separate payload removes the need
  /// to use a BSON Array. For example, Payload Type 1 allows an array of
  /// documents to be specified as a sequence of BSON documents on the wire
  /// without the overhead of array keys.
  /// MongoDB 3.6 only allows certain command arguments to be provided this way.
  /// These are:
  /// Command Name 	Command Argument
  ///    insert 	     documents
  ///    update 	     updates
  ///    delete 	     deletes
  static List<String> pulledOutCommand = <String>[
    keyInsert,
    keyUpdate,
    keyDelete
  ];

  int flags;
  int responseFlags;
  List<Section> sections;

  MongoModernMessage.fromBuffer(BsonBinary buffer) {
    opcode = MongoMessage.ModernMessage;
    deserialize(buffer);
  }

  MongoModernMessage(Map<String, dynamic> document,
      {bool checksumPresent, bool moreToCome, bool exhaustAllowed}) {
    checksumPresent ??= false;
    moreToCome ??= false;
    exhaustAllowed ??= false;

    opcode = MongoMessage.ModernMessage;

    flags = 0;
    if (checksumPresent) {
      flags |= flagCheckSumPresent;
    }
    if (moreToCome) {
      flags |= flagMoreToCome;
    }
    if (exhaustAllowed) {
      flags |= flagExhaustAllowed;
    }

    sections = createSections(document);
  }

  List<Section> createSections(Map<String, dynamic> doc) {
    var ret = <Section>[];
    var isPulledOutCommand = false;
    var keys = doc?.keys?.toList();

    if (keys == null || keys.isEmpty) {
      throw MongoDartError(
          'Invalid document received for Mongo Modern Message');
    }

    /// The command name MUST continue to be the first key of the
    /// command arguments in the Payload Type 0 section.
    var indexOfCommandName = commandName.indexOf(keys.first);
    if (indexOfCommandName == notFound) {
      throw MongoDartError(
          'The first entry ("${keys.first}") of the document is not a command name');
    }
    if (pulledOutCommand.contains(keys.first)) {
      isPulledOutCommand = true;
    }

    // Todo more controls
    if (!isPulledOutCommand) {
      ret.add(Section(basePayloadType, doc));
      return ret;
    }

    var argumentName = commandArgument[indexOfCommandName];
    var data = doc[argumentName] as List<Map<String, Object>>;
    if (data == null) {
      throw MongoDartError('The command ${keys.first} requires an element with '
          'key $argumentName');
    }
    doc.remove(argumentName);
    ret.add(Section(basePayloadType, doc));
    var totalElements = data.length;

    List<Map<String, Object>> sectionList;
    while (totalElements > 0) {
      if (totalElements > maxDocumentsPerPayload1) {
        sectionList = data.sublist(0, maxDocumentsPerPayload1);
      } else {
        sectionList = data.sublist(0, totalElements);
      }
      ret.add(Section(documentsPayloadType, {argumentName: sectionList}));
      totalElements -= maxDocumentsPerPayload1;
    }
    return ret;
  }

  @override
  int get messageLength {
    var sectionsSize = 0;
    for (var section in sections) {
      sectionsSize += section.byteLength;
    }
    return 16 + 4 + sectionsSize;
  }

  @override
  BsonBinary serialize() {
    var buffer = BsonBinary(messageLength);
    writeMessageHeaderTo(buffer);
    buffer.writeInt(flags);
    for (var section in sections) {
      section.packValue(buffer);
    }
    buffer.offset = 0;
    return buffer;
  }

  @override
  MongoResponseMessage deserialize(BsonBinary buffer) {
    sections = <Section>[];
    readMessageHeaderFrom(buffer);
    responseFlags = buffer.readInt32();

    if (buffer.byteArray.lengthInBytes != super.messageLength) {
      throw MongoDartError('The length of the buffer received '
          '(${buffer.byteLength()}) is not what expected '
          '(${super.messageLength})');
    }
    while (buffer.offset < super.messageLength) {
      sections.add(Section.fromBuffer(buffer));
    }

    return this;
  }

  @override
  String toString() {
    if (sections.length == 1) {
      return 'MongoModernMessage($requestId, ${sections[0]})';
    }
    return 'MongoModernMessage($requestId, ${sections.length} sections)';
  }
}
