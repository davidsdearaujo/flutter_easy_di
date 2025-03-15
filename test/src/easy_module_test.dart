import 'package:flutter/material.dart';
import 'package:flutter_easy_di/flutter_easy_di.dart';
import 'package:flutter_easy_di/logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Logger.disable();
  group('$EasyModule', () {
    late TestModule testModule;

    setUp(() {
      testModule = TestModule();
    });

    tearDown(() {
      EasyDI.reset();
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

    testWidgets('$EasyModule.get retrieves dependency from context', (tester) async {
      await EasyDI.initModules([TestModule()]);
      await tester.pumpWidget(MaterialApp(
        home: EasyModuleWidget<TestModule>(
          child: Builder(
            builder: (context) {
              final value = EasyDI.get<String>(context);
              return Text(value);
            },
          ),
        ),
      ));

      expect(find.text('test'), findsOneWidget);
    });
    testWidgets('$EasyModule.of returns data from module', (tester) async {
      final testModule = TestModule();
      await EasyDI.initModules([testModule]);
      await tester.pumpWidget(MaterialApp(
        home: EasyModuleWidget<TestModule>(
          child: Builder(
            builder: (context) {
              final EasyModule? module = EasyModule.of(context);
              final TestModule testingModule = (module as TestModule);
              return Text(testingModule.moduleName);
            },
          ),
        ),
      ));

      expect(find.text('TestModule'), findsOneWidget);
    });

    testWidgets('$EasyModule.of retrieves module instance from context', (tester) async {
      final testModule = TestModule();
      await EasyDI.initModules([testModule]);
      await tester.pumpWidget(
        EasyModuleWidget<TestModule>(
          child: Builder(
            builder: (context) {
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      final context = tester.element(find.byType(SizedBox));
      final module = EasyModule.of(context);
      expect(module, equals(testModule));
    });

    testWidgets('$EasyModule.of - use a parameter from the module', (tester) async {
      await EasyDI.initModules([testModule]);
      await tester.pumpWidget(MaterialApp(
        home: EasyModuleWidget<TestModule>(
          child: Builder(
            builder: (context) {
              final EasyModule? module = EasyModule.of(context);
              final TestModule testingModule = (module as TestModule);
              return Text(testingModule.moduleName);
            },
          ),
        ),
      ));

      expect(find.text('TestModule'), findsOneWidget);
    });
  });
}

// Test implementations
class TestModule extends EasyModule {
  String get moduleName => "TestModule";

  @override
  List<Type> get imports => [];

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    i.addSingleton<String>(() => 'test');
    i.addSingleton<DisposableService>(DisposableService.new);
  }
}

class ImportingModule extends EasyModule {
  @override
  List<Type> get imports => [TestModule];

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    i.addSingleton<int>(() => 42);
  }
}

class SelfImportingModule extends EasyModule {
  @override
  List<Type> get imports => [SelfImportingModule];

  @override
  Future<void> registerBinds(InjectorRegister i) async {}
}

class DuplicateImportsModule extends EasyModule {
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
