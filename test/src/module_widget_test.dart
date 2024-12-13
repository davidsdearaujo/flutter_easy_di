import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_di/modular_di.dart';
import 'package:modular_di/src/module_widget.dart';

void main() {
  group('ModuleWidget', () {
    late TestModule testModule;

    setUp(() {
      testModule = TestModule();
      ModulesManager.instance.registerModule(testModule);
    });

    tearDown(() {
      ModulesManager.instance.dispose();
    });

    testWidgets('should provide module to children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ModuleWidget<TestModule>(
            child: Builder(
              builder: (context) {
                final moduleWidget = ModuleInheritedWidget.of(context);
                expect(moduleWidget?.module, isA<TestModule>());
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should auto-dispose module when widget is disposed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ModuleWidget<TestModule>(
            autoDispose: true,
            child: SizedBox(),
          ),
        ),
      );

      expect(testModule.resetted, isFalse);

      // Dispose widget by replacing it
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(testModule.resetted, isTrue);
    });

    testWidgets('should not dispose module when autoDispose is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ModuleWidget<TestModule>(
            autoDispose: false,
            child: SizedBox(),
          ),
        ),
      );

      expect(testModule.resetted, isFalse);

      // Dispose widget
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(testModule.resetted, isFalse);
    });

    testWidgets('should render child when module is not found', (tester) async {
      ModulesManager.instance.dispose(); // Remove all modules
      await tester.pumpWidget(
        MaterialApp(
          home: ModuleWidget<TestModule>(
            child: Builder(
              builder: (context) {
                final moduleWidget = ModuleInheritedWidget.of(context);
                expect(moduleWidget, isNull);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });
  });
}

// Test module class
class TestModule extends Module {
  bool resetted = false;

  @override
  Future<void> reset([void Function(dynamic)? onDispose]) async {
    resetted = true;
    super.reset(onDispose);
  }

  @override
  List<Type> imports = [];

  @override
  FutureOr<void> registerBinds(InjectorRegister i) {}
}
