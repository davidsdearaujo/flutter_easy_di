import 'dart:async';

import 'package:flutter_easy_di/flutter_easy_di.dart';
import 'package:flutter_easy_di/logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Logger.disable();
  group('$EasyDI', () {
    late MockModuleA moduleA;
    late MockModuleB moduleB;
    late MockModuleC moduleC;

    setUp(() {
      moduleA = MockModuleA();
      moduleB = MockModuleB();
      moduleC = MockModuleC();
    });

    tearDown(() {
      EasyDI.reset();
    });

    test('registerModules adds a single module', () {
      EasyDI.registerModules([moduleA]);
      expect(EasyDI.getModule<MockModuleA>(), equals(moduleA));
    });

    test('registerModules adds multiple modules', () {
      EasyDI.registerModules([moduleA, moduleB]);
      expect(EasyDI.getModule<MockModuleA>(), equals(moduleA));
      expect(EasyDI.getModule<MockModuleB>(), equals(moduleB));
    });

    test('initModules registers and initializes modules', () async {
      await EasyDI.initModules([moduleA, moduleB]);
      expect(moduleA.injector, isNotNull);
      expect(moduleB.injector, isNotNull);
    });

    test('modules are properly linked through imports', () async {
      await EasyDI.initModules([moduleA, moduleB]);
      expect(moduleB.importsModule(moduleA), isTrue);
      expect(moduleA.importsModule(moduleB), isFalse);
    });

    test('disposeModule resets module and dependencies', () async {
      await EasyDI.initModules([moduleA, moduleB, moduleC]);

      final moduleAID = moduleA.injector?.tag;
      final moduleBID = moduleB.injector?.tag;
      final moduleCID = moduleC.injector?.tag;

      // Verify initial tag
      expect(moduleAID, isNotNull);
      expect(moduleBID, isNotNull);
      expect(moduleCID, isNotNull);

      // Dispose moduleA
      await EasyDI.disposeModule<MockModuleA>();

      // Verify moduleA and dependent modules were reset
      expect(moduleA.injector!.tag, isNot(moduleAID));
      expect(moduleB.injector!.tag, isNot(moduleBID));
      expect(moduleC.injector!.tag, isNot(moduleCID));
    });

    test('getModule throws when module not found', () {
      expect(EasyDI.getModule<MockModuleA>(), null);
    });

    test('disposeModule throws when module not found', () {
      expect(() => EasyDI.disposeModule<MockModuleA>(), throwsException);
    });

    test('circular dependencies are detected', () async {
      // Create modules with circular dependency
      final circularA = CircularA();
      final circularB = CircularB();

      // Attempting to initialize should throw
      expect(() => EasyDI.initModules([circularA, circularB]), throwsException);
    });
  });
}

// Mock modules for testing
class MockModuleA extends EasyModule {
  @override
  List<Type> get imports => [];

  @override
  FutureOr<void> registerBinds(InjectorRegister i) {}
}

class MockModuleB extends EasyModule {
  @override
  List<Type> get imports => [MockModuleA];

  @override
  FutureOr<void> registerBinds(InjectorRegister i) {}
}

class MockModuleC extends EasyModule {
  @override
  List<Type> get imports => [MockModuleB];

  @override
  FutureOr<void> registerBinds(InjectorRegister i) {}
}

class CircularA extends EasyModule {
  @override
  List<Type> get imports => [CircularB];

  @override
  FutureOr<void> registerBinds(InjectorRegister i) {}
}

class CircularB extends EasyModule {
  @override
  List<Type> get imports => [CircularA];

  @override
  FutureOr<void> registerBinds(InjectorRegister i) {}
}
