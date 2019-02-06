import 'dart:async';

/// Runs a function repeatedly using exponential backoff until canceled.
class ExponentialBackoff {
  ExponentialBackoff(this.function,
      [this.delay = const Duration(milliseconds: 500)])
      : _duration = delay {
    _run();
  }

  /// The function to run.
  final Future<void> Function() function;

  /// The initial delay. The delay will be doubled between each try (e.g. 500ms,
  /// 1s, 2s, 4s, etc.).
  final Duration delay;
  Duration _duration;

  bool get canceled => _canceled;
  bool _canceled = false;

  /// The number of times the function has been called.
  int get tries => _tries;
  int _tries = 0;

  Timer _timer;

  /// Cancels the exponential backoff irreversibly.
  /// The [function] will not be called again.
  void cancel() {
    _timer.cancel();
    _canceled = true;
  }

  void _run() {
    _timer = Timer(_duration, () async {
      if (!canceled) {
        await function();
        if (!canceled) {
          _duration = Duration(milliseconds: _duration.inMilliseconds * 2);
          _run();
          // This is just to prevent nesting the timer functions, instead
          // letting each one complete and be garbage collected.
          // Future.delayed(Duration(microseconds: 1), _run);
        }
      }
    });
  }
}
