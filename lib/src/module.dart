// Copyright (c) 2024 David Araujo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:async';

// ignore: implementation_imports
import 'package:auto_injector/src/auto_injector_base.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

/// A module is a class that contains the dependencies of a feature.
///
/// It can be used to register dependencies, imports, and other configurations.
abstract class Module {
  @visibleForOverriding
  FutureOr<void> registerBinds(InjectorRegister i);

  @visibleForTesting
  CustomAutoInjector? injector;

  @mustBeOverridden
  late List<Type> imports;

  Future<CustomAutoInjector> initialize() async {
    injector = CustomAutoInjector();
    await registerBinds(injector!);
    return injector!;
  }

  void dispose([void Function(dynamic)? instanceCallback]) {
    injector?.dispose(instanceCallback);
  }
}

abstract interface class InjectorRegister {
  void add<T>(Function constructor, {String? key});
  void addSingleton<T>(Function constructor, {String? key});
  void addLazySingleton<T>(Function constructor, {String? key});
  void addInstance<T>(T instance, {String? key});
  void replace<T>(T instance, {String? key});

  void commit();
}

class CustomAutoInjector extends AutoInjectorImpl implements InjectorRegister {
  CustomAutoInjector.tag(String tag, void Function(AutoInjector injector)? on) : super(tag, [], on);
  factory CustomAutoInjector([void Function(AutoInjector injector)? on]) {
    final tag = const Uuid().v4();
    return CustomAutoInjector.tag(tag, on);
  }

  @override
  // ignore: invalid_use_of_visible_for_testing_member
  void replace<T>(T instance, {String? key}) => replaceInstance(instance, key: key);
}

class ModulesInitializer {
  final _modules = <Type, Module>{};
  void addModule(Module module) {
    _modules[module.runtimeType] = module;
  }

  void addModules(List<Module> modules) {
    for (final module in modules) {
      _modules[module.runtimeType] = module;
    }
  }

  Future<void> initAllModules() async {
    await Future.wait(_modules.values.map((module) {
      return module.initialize();
    }));
    _proccessImports();
  }

  void _proccessImports() {
    for (var module in _modules.values) {
      for (var importType in module.imports) {
        if (module.injector == null) {
          throw Exception('[ModulesInitializer] module "${module.runtimeType}" not initialized.');
        }

        final import = _modules[importType];
        if (import == null) {
          throw Exception('[ModulesInitializer] module "$importType" not found.');
        }
        if (import.injector == null) {
          throw Exception('[ModulesInitializer] module "$importType" was not initialized.');
        }
        module.injector!.addInjector(import.injector!);
      }
    }
  }
}
