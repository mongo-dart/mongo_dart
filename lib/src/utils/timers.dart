import 'dart:async';

abstract class RefCounted {
  RefCounted ref();
  RefCounted unref();
  // Specific for the dart implementation
  void clear();
}

abstract class Immediate extends RefCounted {
  Immediate(this.onImmediate);
  bool hasRef();
  Function onImmediate; // to distinguish it from the Timeout class
}

/// Imnediate implementation, even if the ref() unref() clear()
/// methods make no sense because you can logically
/// change this timeout only inside the method that created it
/// because it is executed immediately.
class _ImmediateImpl extends Immediate {
  static const _immediateDelay = Duration(milliseconds: 0);

  bool _started = false;
  bool _activeTimeout = true;

  _ImmediateImpl(Function onImmediate) : super(onImmediate) {
    _launch();
  }

  // Launch the function to be executed after `delay` time
  // If the function was executed already one time, is not launched again
  void _launch() async {
    if (_started || !_activeTimeout) {
      return;
    }

    void runner() async {
      if (!_started && _activeTimeout) {
        _started = true;
        await Future.sync(() {
          onImmediate();
        });
      }
    }

    await Future.delayed(_immediateDelay, runner);
  }

  @override
  bool hasRef() => _activeTimeout && !_started;

  @override
  RefCounted ref() {
    // As we cannot know if the original execution is still to be executed
    // we launch a new one anyway, that will be ignored, if the case,
    // because of the _started flag.
    if (!_started) {
      _activeTimeout = true;
      _launch();
    }
    return this;
  }

  @override
  RefCounted unref() {
    _activeTimeout = false;
    return this;
  }

  @override
  RefCounted clear() {
    _started = true;
    return unref();
  }
}

Immediate setImmediate(Function functionToBeExecuted) =>
    _ImmediateImpl(functionToBeExecuted);

abstract class Timeout extends RefCounted {
  bool hasRef();
  Timeout refresh();
}

class _TimeoutImpl extends Timeout {
  final List<bool> _activeTimeouts = [];
  final Function _toBeExecuted;
  final Duration delay;
  bool _started = false;

  _TimeoutImpl(this._toBeExecuted, this.delay) {
    _launch();
  }

  // Launch the function to be executed after `delay` time
  // If the function was executed already one time, is not launched again
  void _launch() async {
    if (_started) {
      return;
    }
    _activeTimeouts.add(true);
    var runningIndex = _activeTimeouts.length - 1;
    void runner() async {
      if (!_started && _activeTimeouts[runningIndex]) {
        _started = true;
        await Future.sync(() {
          _toBeExecuted();
        });
        if (this is _IntervalImpl) {
          _started = false;
          _launch();
        }
      }
    }

    await Future.delayed(delay, runner);
  }

  @override
  bool hasRef() => _activeTimeouts.last && !_started;

  /// Reactivate an execution that was previously suspended (`unref()`).
  /// If the original delay time has expired, it launches a new one,
  /// but the delay will start from now...
  @override
  RefCounted ref() {
    // As we cannot know if the original execution is still to be executed
    // we launch a new one anyway, that will be ignored, if the case,
    // because of the _started flag.
    if (!_started) {
      _activeTimeouts.last = true;
      _launch();
    }
    return this;
  }

  /// Launch again the function with  `delay` starting
  /// from now, only if the previous method has not yet been executed.
  /// If launch is successful, the original execution will be ignored.
  @override
  Timeout refresh() {
    if (!_started) {
      _activeTimeouts.last = false;
      _launch();
    }
    return this;
  }

  /// Suspend the execution (in the sense that will not be executed), but,
  /// if already running, there is no way to stop it.
  @override
  RefCounted unref() {
    _activeTimeouts.last = false;
    return this;
  }

  /// Set this timeout as already executed, so, even if reactived,
  /// the original function will not be executed.
  /// If the method is running, no way to stop it.
  ///
  /// This method cannot be reverted.
  @override
  RefCounted clear() {
    _started = true;
    return unref();
  }
}

Timeout setTimeout(Function functionToBeExecuted, Duration delay) =>
    _TimeoutImpl(functionToBeExecuted, delay);

class _IntervalImpl extends _TimeoutImpl {
  _IntervalImpl(Function toBeExecuted, Duration delay)
      : super(toBeExecuted, delay);
}

Timeout setInterval(Function functionToBeExecuted, Duration delay) =>
    _IntervalImpl(functionToBeExecuted, delay);
