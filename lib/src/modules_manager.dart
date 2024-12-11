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

// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'module.dart';

/// A singleton class responsible for initializing and managing modules.
///
/// This class handles the registration, initialization and dependency injection
/// between modules. It maintains a map of module types to module instances and
/// processes module imports to establish dependencies.
class ModulesManager {
  /// The singleton instance of [ModulesManager].
  static final instance = ModulesManager._();
  ModulesManager._();

  final _modules = <Type, Module>{};

  /// ### A simple way to initialize all modules in the list.
  ///
  /// This method adds the modules to the initializer and then initializes them.
  ///
  /// Throws an exception if any module is not found or not initialized.
  ///
  /// **Note: If you want to use modules in separate packages, you should use
  /// [ModulesManager.instance.addModules] and [ModulesManager.instance.initAllModules]
  /// instead.**
  Future<void> initModules(List<Module> modules) async {
    addModules(modules);
    await initAllModules();
  }

  /// ### Adds a single module to the initializer.
  ///
  /// The module is stored with its runtime type as the key.
  void addModule(Module module) {
    _modules[module.runtimeType] = module;
  }

  /// ### Adds multiple modules to the initializer.
  ///
  /// Each module is stored with its runtime type as the key.
  void addModules(List<Module> modules) {
    for (final module in modules) {
      _modules[module.runtimeType] = module;
    }
  }

  /// ### Gets a module instance of type [T] if it exists.
  ///
  /// Returns null if the module is not found.
  /// Commits the module's injector before returning.
  T? getModule<T extends Module>() {
    final module = _modules[T] as T?;
    if (module?.injector case CustomAutoInjector injector when !injector.committed) {
      injector.commit();
    }
    return module;
  }

  /// ### Disposes a module and reloads all modules that depend on it.
  ///
  /// This method disposes the module and then reloads all modules that depend on it.
  ///
  /// Throws an exception if the module is not found.
  Future<void> disposeModule<T extends Module>() async {
    final module = _modules[T] as T?;
    if (module case T module) {
      await module.reset();
      _proccessModuleImports<T>(module);
      await _reloadModulesThatDependOn(module);
    }
  }

  /// ### Initializes all registered modules and processes their imports.
  ///
  /// This method must be called after all modules are added and before
  /// they are used.
  Future<void> initAllModules() async {
    await Future.wait(_modules.values.map((module) {
      return module.initialize();
    }));
    _proccessImports();
  }

  /// ### Processes the imports for all modules.
  ///
  /// For each module, this method:
  /// 1. Verifies the module is initialized
  /// 2. Checks that all imported modules exist and are initialized
  /// 3. Adds the imported module's injector to the importing module
  void _proccessImports() {
    for (var module in _modules.values) {
      _proccessModuleImports(module);
    }
  }

  /// ### Processes the imports for a single module.
  ///
  /// This method:
  /// 1. Verifies the module is initialized
  /// 2. Checks that all imported modules exist and are initialized
  /// 3. Adds the imported module's injector to the importing module
  void _proccessModuleImports<T extends Module>(T module) {
    for (var importType in module.imports) {
      if (module.injector == null) {
        throw Exception('[$ModulesManager] module "${module.runtimeType}" not initialized.');
      }

      final import = _modules[importType];
      if (import == null) {
        throw Exception('[$ModulesManager] module "$importType" not found.');
      }
      if (import.injector == null) {
        throw Exception('[$ModulesManager] module "$importType" was not initialized.');
      }
      module.injector!.addInjector(import.injector!);
    }
  }

  /// ### Reloads all modules that depend on a given module **(recursively)**.
  ///
  /// This method is used to **recursively** reload all modules that depend on a given module
  /// when it is disposed.
  Future<void> _reloadModulesThatDependOn<T extends Module>(T dependModule) async {
    for (var module in _modules.values) {
      if (module == dependModule) continue;
      if (module.imports.contains(dependModule.runtimeType)) {
        await module.reset();
        _proccessModuleImports(module);
        await _reloadModulesThatDependOn(module);

        module.injector?.commit();
        // ignore: invalid_use_of_protected_member
        module.notifyListeners();
      }
    }
  }
}
