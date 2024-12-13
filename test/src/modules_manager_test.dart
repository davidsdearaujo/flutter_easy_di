import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_di/logger.dart';
import 'package:modular_di/src/module.dart';
import 'package:modular_di/src/modules_manager.dart';

void main() {
  Logger.disable();
  group('$ModulesManager', () {
    late ModulesManager manager;
    late MockModuleA moduleA;
    late MockModuleB moduleB;
    late MockModuleC moduleC;

    setUp(() {
      manager = ModulesManager();
      moduleA = MockModuleA();
      moduleB = MockModuleB();
      moduleC = MockModuleC();
    });

    test('registerModule adds a single module', () {
      manager.registerModule(moduleA);
      expect(manager.getModule<MockModuleA>(), equals(moduleA));
    });

    test('registerModules adds multiple modules', () {
      manager.registerModules([moduleA, moduleB]);
      expect(manager.getModule<MockModuleA>(), equals(moduleA));
      expect(manager.getModule<MockModuleB>(), equals(moduleB));
    });

    test('initModules registers and initializes modules', () async {
      await manager.initModules([moduleA, moduleB]);
      expect(moduleA.injector, isNotNull);
      expect(moduleB.injector, isNotNull);
    });

    test('modules are properly linked through imports', () async {
      await manager.initModules([moduleA, moduleB]);
      expect(moduleB.importsModule(moduleA), isTrue);
      expect(moduleA.importsModule(moduleB), isFalse);
    });

    test('disposeModule resets module and dependencies', () async {
      await manager.initModules([moduleA, moduleB, moduleC]);

      final moduleAID = moduleA.injector?.tag;
      final moduleBID = moduleB.injector?.tag;
      final moduleCID = moduleC.injector?.tag;

      // Verify initial tag
      expect(moduleAID, isNotNull);
      expect(moduleBID, isNotNull);
      expect(moduleCID, isNotNull);

      // Dispose moduleA
      await manager.disposeModule<MockModuleA>();

      // Verify moduleA and dependent modules were reset
      expect(moduleA.injector!.tag, isNot(moduleAID));
      expect(moduleB.injector!.tag, isNot(moduleBID));
      expect(moduleC.injector!.tag, isNot(moduleCID));
    });

    test('getModule throws when module not found', () {
      expect(manager.getModule<MockModuleA>(), null);
    });

    test('disposeModule throws when module not found', () {
      expect(() => manager.disposeModule<MockModuleA>(), throwsException);
    });

    test('circular dependencies are detected', () async {
      // Create modules with circular dependency
      final circularA = CircularA();
      final circularB = CircularB();

      // Attempting to initialize should throw
      expect(() => manager.initModules([circularA, circularB]), throwsException);
    });
  });
}

// Mock modules for testing
class MockModuleA extends Module {
  @override
  List<Type> get imports => [];

  @override
  FutureOr<void> registerBinds(InjectorRegister i) {}
}

class MockModuleB extends Module {
  @override
  List<Type> get imports => [MockModuleA];

  @override
  FutureOr<void> registerBinds(InjectorRegister i) {}
}

class MockModuleC extends Module {
  @override
  List<Type> get imports => [MockModuleB];

  @override
  FutureOr<void> registerBinds(InjectorRegister i) {}
}

class CircularA extends Module {
  @override
  List<Type> get imports => [CircularB];

  @override
  FutureOr<void> registerBinds(InjectorRegister i) {}
}

class CircularB extends Module {
  @override
  List<Type> get imports => [CircularA];

  @override
  FutureOr<void> registerBinds(InjectorRegister i) {}
}
