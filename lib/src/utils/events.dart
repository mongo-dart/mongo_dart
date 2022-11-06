import 'dart:async';

import 'error.dart';

String extractType<T>([T? object]) => object is Type ? '$object' : '$T';

abstract class Event {
  late String _identifier;
  Event() {
    _identifier = extractType(this);
  }

  String get identifier => _identifier;
}

class ErrorMonitor extends Event {
  Object error;
  StackTrace? stackTrace;

  ErrorMonitor(this.error, [this.stackTrace]);
}

typedef ListenerFunction<T extends Event> = FutureOr<void> Function(T);

typedef EmitFunction = Future<void> Function(Event event);

class ListenerWrapper<T extends Event> {
  final EventEmitter _emitter;
  final ListenerFunction<T> _fn;
  final bool runOnlyOnce;

  ListenerWrapper(this._emitter, this._fn, {bool? runOnlyOnce})
      : runOnlyOnce = runOnlyOnce ?? false;

  FutureOr<void> run(T event) async {
    try {
      await _fn(event);
      if (runOnlyOnce) {
        _emitter.removeListener(_fn);
      }
    } catch (e) {
      // Do nothing
    }
  }

  ListenerFunction<T> get listener => _fn;
  bool isListener(ListenerFunction<T> listener) => identical(_fn, listener);
}

mixin EventEmitter {
  // String identifier (in case of multiple listeners) and functions
  // to be called
  final Map<String, Set<ListenerWrapper>> _listeners =
      <String, Set<ListenerWrapper>>{};
  final legalEvents = <String>{extractType(ErrorMonitor)};

  void addLegalEvent<T extends Event>() => legalEvents.add(extractType<T>());

  /// Syntactic Sugar for function addListener
  void on<T extends Event>(ListenerFunction<T> listener) =>
      addListener(listener);

  void _addListener<T extends Event>(ListenerFunction<T> listener,
      {bool? setAsFirst}) {
    setAsFirst ??= false;
    var key = extractType<T>();
    if (!legalEvents.contains(key)) {
      throw MongoError(
          'The class "${extractType(this)}" does not emit $key events');
    }
    var listeners = _listeners[key] ?? <ListenerWrapper<T>>{};
    if (setAsFirst) {
      listeners = {ListenerWrapper<T>(this, listener), ...listeners};
    } else {
      listeners.add(ListenerWrapper<T>(this, listener));
    }
    _listeners[key] = listeners;
  }

  void addListener<T extends Event>(ListenerFunction<T> listener) =>
      _addListener<T>(listener);

  void prependListener<T extends Event>(ListenerFunction<T> listener) =>
      _addListener<T>(listener, setAsFirst: true);

  void once<T extends Event>(ListenerFunction<T> listener) =>
      _once<T>(listener);

  void prependOnceListener<T extends Event>(ListenerFunction<T> listener) =>
      _once<T>(listener, setAsFirst: true);

  void _once<T extends Event>(ListenerFunction<T> listener,
      {bool? setAsFirst}) {
    setAsFirst ??= false;
    var key = extractType<T>();
    if (!legalEvents.contains(key)) {
      throw MongoError(
          'The class "${extractType(this)}" does not emit $key events');
    }
    var listeners = _listeners[key] ?? <ListenerWrapper<T>>{};
    if (setAsFirst) {
      listeners = {
        ListenerWrapper<T>(this, listener, runOnlyOnce: true),
        ...listeners
      };
    } else {
      listeners.add(ListenerWrapper<T>(this, listener, runOnlyOnce: true));
    }
    _listeners[key] = listeners;
  }

  /// Syntactic Sugar for function removeListener
  void off<T extends Event>(ListenerFunction<T> listener) =>
      removeListener(listener);

  void removeListener<T extends Event>(ListenerFunction<T> listener) {
    var key = extractType<T>();

    if (_listeners.containsKey(key)) {
      final listeners = _listeners[key]! as Set<ListenerWrapper<T>>;
      listeners.removeWhere(
          (listenerWrapper) => listenerWrapper.isListener(listener));
    }
  }

  Future<bool> emit<T extends Event>(T event) async {
    var key = extractType<T>();
    if (!legalEvents.contains(key)) {
      throw MongoError(
          'The class "${extractType(this)}" does not emit $key events');
    }
    var atLeastOneListener = false;
    if (_listeners.containsKey(key)) {
      final listeners = _listeners[key]!;

      for (var listenerWrapper in listeners) {
        atLeastOneListener = true;
        await listenerWrapper.run(event);
      }
    }
    return atLeastOneListener;
  }

  int listenerCount<T extends Event>([T? event]) {
    var key = extractType(event);
    if (!legalEvents.contains(key)) {
      throw MongoError(
          'The class "${extractType(this)}" does not emit $key events');
    }
    if (_listeners.containsKey(key)) {
      final listeners = _listeners[key]!;

      return listeners.length;
    }
    return 0;
  }

  List<ListenerFunction<T>> rawListeners<T extends Event>([T? event]) {
    var key = extractType(event);
    if (!legalEvents.contains(key)) {
      throw MongoError(
          'The class "${extractType(this)}" does not emit $key events');
    }
    var ret = <ListenerFunction<T>>[];
    if (_listeners.containsKey(key)) {
      var listenerWrappers = _listeners[key]! as Set<ListenerWrapper<T>>;
      for (var wrapper in listenerWrappers) {
        ret.add(wrapper.listener);
      }
    }
    return ret;
  }
}
