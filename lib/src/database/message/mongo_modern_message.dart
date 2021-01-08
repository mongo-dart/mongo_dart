import 'package:mongo_dart/mongo_dart.dart'
    show BsonBinary, MongoDartError, MongoMessage;
import 'package:mongo_dart/src/database/message/additional/section.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

import 'mongo_response_message.dart';

const int notFound = -1;

class MongoModernMessage extends MongoResponseMessage {
  /// The maximum permitted size of a BSON object in bytes for this mongod
  /// process. If not provided, clients should assume a max size
  /// of “16 * 1024 * 1024” (16MB).
  /// It is set when connecting from the isMaster command
  static int maxBsonObjectSize = 16777216;

  /// The maximum permitted size of a BSON wire protocol message.
  /// The default value is 48000000 bytes
  /// It is set when connecting from the isMaster command
  static int maxMessageSizeBytes = 48000000;

  /// The maximum number of write operations permitted in a write batch.
  /// If a batch exceeds this limit, the client driver divides the batch into
  /// smaller groups each with counts less than or equal to the value of
  /// this field.
  ///
  /// The value of this limit is 100,000 writes.
  ///
  /// It is set when connecting from the isMaster command
  static int maxWriteBatchSize = 100000;

  static const int basePayloadType = 0;
  static const int documentsPayloadType = 1;

  // Maybe that this is not necessary, but I created small sections if needed.
  // It is not clear in the documentation why we can have more than one section
  // of type 1. I assumed that is because of the size.
  // If this assumption is wrong, please remove this logic.
  // Edit. It seems that the server only accept one section of type 1
  // Tried creating two sections of type 1 on insert
  // but got error message that "insert.documents document sequence is
  // duplicated". And that is OK. Tried to suffix a counter ("documents_1,
  // etc..."), but got the error "insert.documents_1 is an unknown field"
  // Could not understand if multiple sections of type 1 is to mix commands
  // of different types (insert, update, delete), but in the
  // specifications is stated that the command must be the first
  // element in section one (type 0) map... So, this is how I did it:
  // One command per message, if it can be pulled out, documents are moved to
  // section 1.
  // If The number of documents is bigger than the "maxWriteBatchSize", error.
  // This limit is actually 100,000 documents (4.4).
  // Bulk functions (only) will split a bigger number of documents into
  // the needed number of messages.
  // The splitting logic is left, but it is not operative, as the limit set
  // (1,000,000) is bigger than the "maxWriteBatchSixe". Maybe in the future
  // the number of sections of type 1 will be increased.
  // In this case it will be needed to change the logic with which we are
  // generating the section identifier.
  static int maxDocumentsPerPayload1 = 1000000;

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
    //keyServerStatus,
    //keyFind,
    //keyGetMore,
    //keyKillCursors,
    //keyGetLastError,
    //keyCreate
  ];
  static List<String> commandArgument = <String>[
    keyCreateIndexesArgument,
    keyInsertArgument,
    keyUpdateArgument,
    keyDeleteArgument,
    //null,
    //null,
    //null,
    //null,
    //null,
    //null
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

    if (messageLength > maxMessageSizeBytes) {
      throw MongoDartError('The total message length (${messageLength} bytes) '
          'is bigger than the max allowed limit ($maxMessageSizeBytes bytes)');
    }
  }

  List<Section> createSections(Map<String, dynamic> doc) {
    var ret = <Section>[];
    var isPulledOutCommand = false;
    var keys = doc?.keys?.toList();

    if (keys == null || keys.isEmpty) {
      throw MongoDartError(
          'Invalid document received for Mongo Modern Message');
    }

    if (pulledOutCommand.contains(keys.first)) {
      isPulledOutCommand = true;
    }

    // Todo more controls
    if (!isPulledOutCommand) {
      ret.add(Section(basePayloadType, doc));
      return ret;
    }

    /// The command name MUST continue to be the first key of the
    /// command arguments in the Payload Type 0 section.
    var indexOfCommandName = commandName.indexOf(keys.first);
    if (indexOfCommandName == notFound) {
      throw MongoDartError(
          'The first entry ("${keys.first}") of the document is not a command name');
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
    if (data.length > maxWriteBatchSize) {
      throw MongoDartError('The total number of documents (${data.length}) '
          'is greater than the max allowed ($maxWriteBatchSize)');
    }

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
          '(${buffer.byteLength()} bytes) is not what expected '
          '(${super.messageLength} bytes)');
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
