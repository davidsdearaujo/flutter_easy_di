import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_di/logger.dart';

void main() {
  group('Logger', () {
    // Reset logger state before each test
    setUp(() {
      Logger.disable();
    });

    test('should not log when disabled', () {
      final List<String> logs = [];
      foundation.debugPrint = (String? message, {int? wrapWidth}) {
        logs.add(message ?? '');
      };

      Logger.log('test message');
      expect(logs, isEmpty);
    });

    test('should log when enabled in debug mode', () {
      final List<String> logs = [];
      foundation.debugPrint = (String? message, {int? wrapWidth}) {
        logs.add(message ?? '');
      };

      Logger.enable();
      Logger.log('test message');
      expect(logs, ['test message']);
    });

    test('should handle null messages', () {
      final List<String> logs = [];
      foundation.debugPrint = (String? message, {int? wrapWidth}) {
        logs.add(message ?? '');
      };

      Logger.enable();
      Logger.log(null);
      expect(logs, ['null']);
    });

    test('enable() should turn on logging', () {
      Logger.enable();
      expect(Logger.isEnabled, isTrue);
    });

    test('disable() should turn off logging', () {
      Logger.enable();
      Logger.disable();
      expect(Logger.isEnabled, isFalse);
    });
  });
}
