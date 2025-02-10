import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_di/logger.dart';
import 'package:modular_di/modular_di.dart';

void main() {
  Logger.disable();
  group('$Module', () {
    late TestModule testModule;

    setUp(() {
      testModule = TestModule();
    });

    test('initialize creates injector and registers binds', () async {
      final injector = await testModule.init();
      injector.commit();

      expect(injector, isNotNull);
      expect(testModule.injector, isNotNull);
      expect(injector.get<String>(), equals('test'));
    });

    test('dispose cleans up injector', () async {
      await testModule.init();
      testModule.injector!.commit();
      expect(testModule.injector!.committed, isTrue);

      testModule.dispose();
      expect(testModule.injector!.committed, isFalse);
    });

    test('reset reinitializes the module', () async {
      await testModule.init();
      final firstInjector = testModule.injector;

      await testModule.reset();
      expect(testModule.injector, isNotNull);
      expect(testModule.injector, isNot(equals(firstInjector)));
    });

    test('validateImports throws on self-importing module', () {
      final module = SelfImportingModule();
      expect(() => module.validateImports(), throwsException);
    });

    test('validateImports throws on duplicate imports', () {
      final module = DuplicateImportsModule();
      expect(() => module.validateImports(), throwsException);
    });

    test('disposeSingleton removes specific instance', () async {
      final module = TestModule();
      await module.init();
      module.injector!.commit();

      final service = module.injector!.get<DisposableService>();
      final disposed = module.injector!.disposeSingleton<DisposableService>();

      expect(disposed, equals(service));
      expect(module.injector!.get<DisposableService>(), isNot(equals(service)));
    });

    testWidgets('Module.get retrieves dependency from context', (tester) async {
      await ModulesManager.instance.initModules([TestModule()]);
      await tester.pumpWidget(MaterialApp(
        home: ModuleWidget<TestModule>(
          child: Builder(
            builder: (context) {
              final value = Module.get<String>(context);
              return Text(value);
            },
          ),
        ),
      ));

      expect(find.text('test'), findsOneWidget);
    });
    testWidgets('Module.of retrieves module instance from context', (tester) async {
      await ModulesManager.instance.initModules([TestModule()]);
      await tester.pumpWidget(MaterialApp(
        home: ModuleWidget<TestModule>(
          child: Builder(
            builder: (context) {
              final Module? module = Module.of(context);
              final TestModule testingModule = (module as TestModule);
              return Text(testingModule.moduleName);
            },
          ),
        ),
      ));

      expect(find.text('TestModule'), findsOneWidget);
    });

    testWidgets('Module.get throws when no module in context', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            String text = '';
            try {
              Module.get<String>(context);
              text = 'Should not reach here';
            } catch (e) {
              text = 'Error thrown';
            }
            return Text(text);
          },
        ),
      ));

      expect(find.text('Error thrown'), findsOneWidget);
    });
  });
}

// Test implementations
class TestModule extends Module {
  String get moduleName => "TestModule";

  @override
  List<Type> get imports => [];

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    i.addSingleton<String>(() => 'test');
    i.addSingleton<DisposableService>(DisposableService.new);
  }
}

class ImportingModule extends Module {
  @override
  List<Type> get imports => [TestModule];

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    i.addSingleton<int>(() => 42);
  }
}

class SelfImportingModule extends Module {
  @override
  List<Type> get imports => [SelfImportingModule];

  @override
  Future<void> registerBinds(InjectorRegister i) async {}
}

class DuplicateImportsModule extends Module {
  @override
  List<Type> get imports => [TestModule, TestModule];

  @override
  Future<void> registerBinds(InjectorRegister i) async {}
}

class DisposableService {
  bool disposed = false;
  void dispose() {
    disposed = true;
  }
}
