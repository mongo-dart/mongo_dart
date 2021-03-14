import 'package:mongo_dart/src/database/commands/mixin/basic_result.dart';

import 'write_concern_error.dart';
import 'package:mongo_dart/src/database/utils/map_keys.dart';

enum WriteCommandType { insert, update, delete }

abstract class AbstractWriteResult with BasicResult {
  AbstractWriteResult.fromMap(
      this.writeCommandType, Map<String, Object> result) {
    extractBasic(result);

    serverResponses = [result];
    //ok = result[keyOk];
    switch (writeCommandType) {
      case WriteCommandType.insert:
        nInserted = result[keyN] ?? 0;
        break;
      case WriteCommandType.update:
        nMatched = result[keyN] ?? 0;
        break;
      case WriteCommandType.delete:
        nRemoved = result[keyN] ?? 0;
        break;
    }
    if (result.containsKey(keyNModified)) {
      nModified = result[keyNModified];
    }
    if (result[keyUpserted] != null) {
      nUpserted = (result[keyUpserted] as List).length;
    }
    if (result.containsKey(keyWriteConcernError)) {
      writeConcernError =
          WriteConcernError.fromMap(result[keyWriteConcernError]);
    }
  }

  /// This is the original response from the server;
  List<Map<String, Object>> serverResponses;

  /// The command that generated this output;
  WriteCommandType writeCommandType;

  /// The number of documents inserted, excluding upserted documents.
  /// See nUpserted for the number of documents inserted
  /// through an upsert.
  int nInserted = 0;

  /// The number of documents selected for update. If the update operation
  /// results in no change to the document, e.g. $set expression updates the
  /// value to the current value, nMatched can be greater than nModified.
  int nMatched = 0;

  /// The number of existing documents updated. If the update/replacement
  /// operation results in no change to the document, such as setting the
  /// value of the field to its current value, nModified can be less than
  /// nMatched.
  int nModified = 0;

  /// The number of documents inserted by an upsert.
  int nUpserted = 0;

  /// The number of documents removed.
  int nRemoved = 0;

  WriteConcernError writeConcernError;

  int get totalInserted => nInserted + nUpserted;

  /// This simply checks the OK value, that could return error (0.0)
  /// if network problems are detected.
  bool get operationSucceeded => ok == 1.0;
  bool checkQueryExpectation(int expectedMatches) =>
      expectedMatches != nMatched;

  bool get hasWriteErrors;
  int get writeErrorsNumber;
  bool get isAcknowledged => writeConcernError == null;
  bool get hasWriteConcernError => !isAcknowledged;

  /// The operation has been completeded successfully and it has been
  /// acknowledged
  /// Please note that if the write concern was not majority the operation
  /// could be rollbacked yet in case of primary failure
  bool get isSuccess {
    if (!isAcknowledged) {
      return false;
    }
    return taskCompleted;
  }

  /// The operation has been completeded successfully but it has not been
  /// acknowledged
  bool get isSuspendedSuccess {
    if (isAcknowledged) {
      return false;
    }
    return taskCompleted;
  }

  /// The operation has been executed, but we don't know anything
  /// about acknowledgment
  bool get taskCompleted {
    if (!operationSucceeded || hasWriteErrors) {
      return false;
    }
    return true;
  }

  /// The operation has been partially executed and it has been acknowledged
  /// Please note that if the write concern was not majority the operation
  /// could be rollbacked yet in case of primary failure
  bool get isPartialSuccess {
    if (!isAcknowledged) {
      return false;
    }
    return isPartial;
  }

  /// The operation has been partially executed and it has not been acknowledged
  bool get isSuspendedPartial {
    if (isAcknowledged) {
      return false;
    }
    return isPartial;
  }

  /// The operation has been partially executed, but we don't know anything
  /// about acknowledgment
  bool get isPartial {
    // Exclude full success
    if (!operationSucceeded || !hasWriteErrors) {
      return false;
    }
    switch (writeCommandType) {
      case WriteCommandType.insert:
        return nInserted > 0;
      case WriteCommandType.update:
        return nModified + nUpserted > 0;
      case WriteCommandType.delete:
        return nRemoved > 0;
      // mixed case, the writeCommandType is Null
      default:
        return nInserted + nModified + nUpserted + nRemoved > 0;
    }
  }

  // Nothing has been processed
  bool get isFailure {
    switch (writeCommandType) {
      case WriteCommandType.insert:
        return nInserted == 0;
      case WriteCommandType.update:
        return nModified + nUpserted == 0;
      case WriteCommandType.delete:
        return nRemoved == 0;
      // mixed case, the writeCommandType is Null
      default:
        return nInserted + nModified + nUpserted + nRemoved == 0;
    }
  }
}
