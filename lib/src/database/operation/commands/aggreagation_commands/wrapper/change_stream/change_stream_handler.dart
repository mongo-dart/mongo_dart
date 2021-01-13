import 'dart:async';

import 'package:mongo_dart/src/database/operation/commands/aggreagation_commands/aggregate/return_classes/change_event.dart';

class ChangeStreamHandler {
  void handleData(
          Map<String, Object> streamData, EventSink<ChangeEvent> sink) =>
      sink.add(ChangeEvent.fromMap(streamData));

  void handleDone(EventSink<ChangeEvent> sink) => sink.close();
  void handleError(error, stacktrace, sink) => sink.addError(error);

  StreamTransformer<Map<String, Object>, ChangeEvent> get transformer =>
      StreamTransformer<Map<String, Object>, ChangeEvent>.fromHandlers(
          handleData: handleData,
          handleError: handleError,
          handleDone: handleDone);
}
