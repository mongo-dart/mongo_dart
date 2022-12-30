import 'dart:async';

import 'package:mongo_dart/src/command/aggregation_commands/aggregate/return_classes/change_event.dart';

class ChangeStreamHandler {
  void handleData(
          Map<String, dynamic> streamData, EventSink<ChangeEvent> sink) =>
      sink.add(ChangeEvent.fromMap(streamData));

  void handleDone(EventSink<ChangeEvent> sink) => sink.close();
  void handleError(error, stacktrace, sink) => sink.addError(error);

  StreamTransformer<Map<String, dynamic>, ChangeEvent> get transformer =>
      StreamTransformer<Map<String, dynamic>, ChangeEvent>.fromHandlers(
          handleData: handleData,
          handleError: handleError,
          handleDone: handleDone);
}
