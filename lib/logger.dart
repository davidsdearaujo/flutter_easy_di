import 'package:flutter/foundation.dart';

/// A utility class for logging messages in debug mode.
///
/// The Logger class provides static methods to control and perform logging operations.
/// Logging can be enabled or disabled globally, and messages are only printed in debug mode.
class Logger {
  /// Whether logging is currently enabled.
  static bool _isEnabled = false;

  /// Expose isEnabled for testing purposes
  @visibleForTesting
  static bool get isEnabled => _isEnabled;

  /// Enables logging functionality.
  ///
  /// After calling this method, subsequent calls to [log] will print messages
  /// when in debug mode.
  static void enable() => _isEnabled = true;

  /// Disables logging functionality.
  ///
  /// After calling this method, subsequent calls to [log] will not print any messages.
  static void disable() => _isEnabled = false;

  /// Logs a message if logging is enabled and the app is in debug mode.
  ///
  /// The message will only be printed if both conditions are met:
  /// 1. Logging is enabled via [enable]
  /// 2. The app is running in debug mode
  ///
  /// Example:
  /// ```dart
  /// Logger.enable();
  /// Logger.log('Debug message'); // Will print in debug mode
  /// Logger.disable();
  /// Logger.log('Debug message'); // Will not print
  /// ```
  static log(Object? message) {
    if (!_isEnabled) return;
    debugPrint(message.toString());
  }
}
