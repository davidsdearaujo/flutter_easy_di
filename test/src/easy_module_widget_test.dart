import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easy_di/flutter_easy_di.dart';
import 'package:flutter_easy_di/src/easy_module_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$EasyModuleWidget', () {
    late TestModule testModule;

    setUp(() {
      testModule = TestModule();
      EasyDI.registerModules([testModule]);
    });

    tearDown(() {
      EasyDI.reset();
    });

    testWidgets('should provide module to children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EasyModuleWidget<TestModule>(
            child: Builder(
              builder: (context) {
                final moduleWidget = EasyModuleInheritedWidget.of(context, listen: true);
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
          home: EasyModuleWidget<TestModule>(
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
          home: EasyModuleWidget<TestModule>(
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
      EasyDI.reset(); // Remove all modules
      await tester.pumpWidget(
        MaterialApp(
          home: EasyModuleWidget<TestModule>(
            child: Builder(
              builder: (context) {
                final moduleWidget = EasyModuleInheritedWidget.of(context, listen: true);
                expect(moduleWidget, isNull);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });
    testWidgets('should render child after module is initialized', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EasyModuleWidget<TestModule>(
            child: GetModuleBeforeInitWidget(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
  });
}

// Test module class
class TestModule extends EasyModule {
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

class GetModuleBeforeInitWidget extends StatefulWidget {
  const GetModuleBeforeInitWidget({super.key});

  @override
  State<GetModuleBeforeInitWidget> createState() => _GetModuleBeforeInitWidgetState();
}

class _GetModuleBeforeInitWidgetState extends State<GetModuleBeforeInitWidget> {
  late final moduleWidget = EasyModuleInheritedWidget.of(context, listen: false);

  @override
  Widget build(BuildContext context) {
    expect(moduleWidget, isNotNull);
    return const SizedBox();
  }
}
