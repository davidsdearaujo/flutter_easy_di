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

import 'package:meta/meta.dart';

import 'module.dart';

/// A singleton class responsible for initializing and managing modules.
///
/// This class handles the registration, initialization and dependency injection
/// between modules. It maintains a map of module types to module instances and
/// processes module imports to establish dependencies.
class ModulesManager {
  /// The singleton instance of [ModulesManager].
  static final instance = ModulesManager();

  @visibleForTesting
  ModulesManager();

  final _modules = <Type, Module>{};

  /// Initializes a list of modules in a single operation.
  ///
  /// This is a convenience method that combines [registerModules] and [initRegisteredModules]
  /// into a single call. It will:
  /// 1. Register all provided modules
  /// 2. Initialize them and process their dependencies
  ///
  /// Example:
  /// ```dart
  /// await ModulesManager.instance.initModules([
  ///   CoreModule(),
  ///   UserModule(),
  ///   AuthModule(),
  /// ]);
  /// ```
  ///
  /// Throws a [StateError] if:
  /// - Any module fails to initialize
  /// - There are circular dependencies between modules
  /// - A required imported module is not found
  ///
  /// For more granular control over module registration and initialization,
  /// use [registerModules] and [initRegisteredModules] separately.
  Future<void> initModules(List<Module> modules) async {
    registerModules(modules);
    await initRegisteredModules();
  }

  /// ### Registers a single module to the initializer.
  ///
  /// The module is stored with its runtime type as the key. This allows the module
  /// to be retrieved later using its type.
  ///
  /// Example:
  /// ```dart
  /// final userModule = UserModule();
  /// ModulesManager.instance.registerModule(userModule);
  /// await ModulesManager.instance.initRegisteredModules();
  /// ```
  ///
  /// **Note:** Use this method if you want to create your own custom initialization logic.
  /// For simpler cases where you just want to initialize all modules at once,
  /// use [initModules] instead.
  ///
  /// See also:
  /// * [registerModules] for registering multiple modules at once
  /// * [initRegisteredModules] for initializing registered modules
  void registerModule(Module module) {
    _modules[module.runtimeType] = module;
  }

  /// ### Registers multiple modules to the initializer.
  ///
  /// Each module is stored with its runtime type as the key. This allows the modules
  /// to be retrieved later using their types.
  ///
  /// Example:
  /// ```dart
  /// ModulesManager.instance.registerModules([
  ///   CoreModule(),
  ///   UserModule(),
  ///   AuthModule(),
  /// ]);
  /// await ModulesManager.instance.initRegisteredModules();
  /// ```
  ///
  /// See also:
  /// * [registerModule] for registering a single module
  /// * [initRegisteredModules] for initializing registered modules
  void registerModules(List<Module> modules) {
    for (final module in modules) {
      registerModule(module); // Reuse existing registerModule logic
    }
  }

  /// ### Initializes all registered modules and processes their imports.
  ///
  /// This method must be called after all modules are added and before
  /// they are used.
  Future<void> initRegisteredModules() async {
    _checkForCircularDependencies();
    await Future.wait(_modules.values.map((module) {
      return module.initialize();
    }));
    _proccessImports();
  }

  /// Checks for circular dependencies between modules.
  ///
  /// Throws an [Exception] if a circular dependency is detected.
  void _checkForCircularDependencies() {
    for (final module in _modules.values) {
      _detectCircularDependency(module, {module.runtimeType});
    }
  }

  void _detectCircularDependency(Module module, Set<Type> visited) {
    for (final importType in module.imports) {
      if (visited.contains(importType)) {
        final cycle = [...visited, importType].map((type) => type.toString()).join(' -> ');
        throw Exception('[$ModulesManager] Circular dependency detected: $cycle');
      }

      final importedModule = _modules[importType];
      if (importedModule != null) {
        visited.add(importType);
        _detectCircularDependency(importedModule, visited);
        visited.remove(importType);
      }
    }
  }

  /// ### Gets a module instance of type [T] if it exists.
  ///
  /// Returns null if the module is not found.
  /// If the module exists but its injector hasn't been committed yet,
  /// this method will commit it before returning.
  ///
  /// **Note: This method is internal and should not be used outside the module manager.**
  /// Use [Module.get] instead to retrieve dependencies.
  @internal
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
  /// After disposing, it will:
  /// 1. Reset the module's state and injector
  /// 2. Re-process its imports to ensure dependencies are properly linked
  /// 3. Recursively reload any modules that depend on this one
  ///
  /// Example:
  /// ```dart
  /// await ModulesManager.instance.disposeModule<UserModule>();
  /// ```
  ///
  /// Throws an [Exception] if the module is not found in the manager.
  Future<void> disposeModule<T extends Module>() async {
    final module = _modules[T] as T?;
    if (module == null) {
      throw Exception('[$ModulesManager] module "$T" not found.');
    }

    await module.reset();
    _proccessModuleImports<T>(module);
    await _reloadModulesThatDependOn(module);
  }

  /// ### Processes the imports for all modules.
  ///
  /// For each module, this method:
  /// {@macro _proccessModuleImports-steps}
  void _proccessImports() {
    for (var module in _modules.values) {
      _proccessModuleImports(module);
    }
  }

  /// ### Processes the imports for a single module.
  ///
  /// This method:
  /// {@template _proccessModuleImports-steps}
  /// 1. Verifies the module is initialized
  /// 2. Checks that all imported modules exist and are initialized
  /// 3. Adds the imported module's injector to the importing module
  /// {@endtemplate}
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
  /// This method recursively reloads all modules that depend on the given module.
  /// When a module is disposed, we need to:
  /// 1. Reset any modules that imported it
  /// 2. Reprocess their imports to ensure dependencies are correct
  /// 3. Recursively handle any modules that depend on the reset modules
  /// 4. Commit changes and notify listeners of the updates
  Future<void> _reloadModulesThatDependOn<T extends Module>(T dependModule) async {
    for (final module in _modules.values) {
      // Skip the disposed module itself
      if (module == dependModule) continue;

      // Check if this module imports the disposed module
      if (module.imports.contains(dependModule.runtimeType)) {
        // Reset the dependent module's state
        await module.reset();

        // Reprocess imports to ensure dependencies are correct
        _proccessModuleImports(module);

        // Recursively handle modules that depend on this one
        await _reloadModulesThatDependOn(module);

        // Commit the module if it hasn't been committed yet
        if (module.injector != null && module.injector!.committed == false) {
          module.injector!.commit();
        }
        // ignore: invalid_use_of_protected_member
        module.notifyListeners();
      }
    }
  }

  @visibleForTesting
  void dispose() {
    for (final module in _modules.values) {
      module.dispose();
    }
    _modules.clear();
  }
}
