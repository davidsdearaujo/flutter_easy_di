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

import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'easy_module.dart';

/// A singleton class responsible for initializing and managing modules.
///
/// This class handles the registration, initialization and dependency injection
/// between modules. It maintains a map of module types to module instances and
/// processes module imports to establish dependencies.
abstract class EasyDI {
  /// ### Disposes all registered modules.
  ///
  /// This method disposes all registered modules and clears the internal modules map.
  /// After disposing, it will:
  /// 1. Reset the module's state and injector
  /// 2. Re-process its imports to ensure dependencies are properly linked
  ///
  /// Example:
  /// ```dart
  /// // In a test file
  /// tearDown(() {
  ///   EasyDI.reset(); // Reset modules between tests
  /// });
  /// ```
  @visibleForTesting
  static void reset() {
    for (final module in _modules.values) {
      module.dispose();
    }
    _modules.clear();
  }

  static final _modules = <Type, EasyModule>{};

  @visibleForTesting
  static UnmodifiableMapView<Type, EasyModule> get modules => UnmodifiableMapView(_modules);

  /// Initializes a list of modules in a single operation.
  ///
  /// This is a convenience method that combines [registerModules] and [initRegisteredModules]
  /// into a single call. It will:
  /// 1. Register all provided modules
  /// 2. Initialize them and process their dependencies
  ///
  /// Example:
  /// ```dart
  /// await EasyDI.initModules([
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
  static Future<void> initModules(List<EasyModule> modules) async {
    registerModules(modules);
    await initRegisteredModules();
  }

  /// ### Registers multiple modules to the initializer.
  ///
  /// Each module is stored with its runtime type as the key. This allows the modules
  /// to be retrieved later using their types.
  ///
  /// Example:
  /// ```dart
  /// EasyDI.registerModules([
  ///   CoreModule(),
  ///   UserModule(),
  ///   AuthModule(),
  /// ]);
  /// await EasyDI.initRegisteredModules();
  /// ```
  ///
  /// See also:
  /// * [initRegisteredModules] for initializing registered modules
  static void registerModules(List<EasyModule> modules) {
    for (final module in modules) {
      _modules[module.runtimeType] = module;
    }
  }

  /// ### Initializes all registered modules and processes their imports.
  ///
  /// This method must be called after all modules are added and before
  /// they are used.
  static Future<void> initRegisteredModules() async {
    _checkForCircularDependencies();
    await Future.wait(_modules.values.map((module) {
      return module.init();
    }));
    _proccessImports();
  }

  /// Checks for circular dependencies between modules.
  ///
  /// Throws an [Exception] if a circular dependency is detected.
  static void _checkForCircularDependencies() {
    for (final module in _modules.values) {
      _detectCircularDependency(module, {module.runtimeType});
    }
  }

  static void _detectCircularDependency(EasyModule module, Set<Type> visited) {
    for (final importType in module.imports) {
      if (visited.contains(importType)) {
        final cycle = [...visited, importType].map((type) => type.toString()).join(' -> ');
        throw Exception('[$EasyDI] Circular dependency detected: $cycle');
      }

      final importedModule = _modules[importType];
      if (importedModule != null) {
        visited.add(importType);
        _detectCircularDependency(importedModule, visited);
        visited.remove(importType);
      }
    }
  }

  /// Gets a dependency of type [T] from the closest [EasyModule] in the widget tree.
  ///
  /// This method searches up the widget tree for a [EasyModuleInheritedWidget] and
  /// retrieves the requested dependency from its module's injector.
  ///
  /// The [listen] parameter determines if the widget should rebuild when the module changes.
  /// If true, the widget will rebuild when the module notifies its listeners.
  /// If false, the widget will not rebuild when the module changes (default).
  ///
  /// Throws an [Exception] if the dependency is not found.
  ///
  /// Example:
  /// ```dart
  /// // Without listening to changes
  /// final repository = Module.get<UserRepository>(context);
  ///
  /// // With listening to changes - widget will rebuild when module changes
  /// class _MyWidgetState extends State<MyWidget> {
  ///   late UserService _userService;
  ///
  ///   @override
  ///   void didChangeDependencies() {
  ///     super.didChangeDependencies();
  ///     _userService = Module.get<UserService>(context, listen: true);
  ///   }
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return Text(_userService.username);
  ///   }
  /// }
  /// ```
  static T get<T extends Object>(BuildContext context, {bool listen = false}) {
    final closestModule = EasyModule.of(context, listen: listen);
    if (closestModule == null) {
      throw Exception('No $EasyModule found in the widget tree');
    }
    if (closestModule.injector == null) {
      throw Exception('$EasyModule ${closestModule.runtimeType} is not initialized');
    }
    try {
      final response = closestModule.injector!.get<T>();
      return response;
    } catch (e) {
      throw Exception('Type $T not found in module ${closestModule.runtimeType}: $e');
    }
  }

  /// ### Gets a module instance of type [T] if it exists.
  ///
  /// Returns null if the module is not found.
  /// If the module exists but its injector hasn't been committed yet,
  /// this method will commit it before returning.
  ///
  /// **Note: This method is internal and should not be used outside the module manager.**
  /// Use [EasyDI.get] instead to retrieve dependencies.
  @internal
  static T? getModule<T extends EasyModule>() {
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
  /// await EasyDI.disposeModule<UserModule>();
  /// ```
  ///
  /// Throws an [Exception] if the module is not found in the manager.
  static Future<void> disposeModule<T extends EasyModule>() async {
    final module = _modules[T] as T?;
    if (module == null) {
      throw Exception('[$EasyDI] module "$T" not found.');
    }

    await module.reset();
    _proccessModuleImports<T>(module);
    await _reloadModulesThatDependOn(module);
  }

  /// ### Processes the imports for all modules.
  ///
  /// For each module, this method:
  /// {@macro _proccessModuleImports-steps}
  static void _proccessImports() {
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
  static void _proccessModuleImports<T extends EasyModule>(T module) {
    for (var importType in module.imports) {
      if (module.injector == null) {
        throw Exception('[$EasyDI] module "${module.runtimeType}" not initialized.');
      }

      final import = _modules[importType];
      if (import == null) {
        throw Exception('[$EasyDI] module "$importType" not found.');
      }
      if (import.injector == null) {
        throw Exception('[$EasyDI] module "$importType" was not initialized.');
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
  static Future<void> _reloadModulesThatDependOn<T extends EasyModule>(T dependModule) async {
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

  /// ### Replaces an instance in all modules that have registered it.
  ///
  /// This method searches through all registered modules and replaces the instance
  /// in any module that has registered a dependency of type T. This is useful when
  /// you don't know which module owns the dependency, but it can be slower than
  /// [replaceFromModule] since it needs to check all modules.
  ///
  /// Example:
  /// ```dart
  /// EasyDI.replace<UserRepository>(mockUserRepository);
  /// ```
  @visibleForTesting
  static void replace<T extends Object>(T instance, {String? key}) {
    for (final module in _modules.values) {
      if (module.injector!.isAdded<T>()) {
        module.injector!.replace<T>(instance, key: key);
      }
    }
  }

  /// ### Replaces an instance in a specific module.
  ///
  /// This method directly replaces an instance in the specified module's injector.
  /// It is faster than [replace] since it targets a specific module rather than
  /// searching through all modules.
  ///
  /// Example:
  /// ```dart
  /// EasyDI.replaceFromModule<AuthModule, UserRepository>(
  ///   mockUserRepository,
  /// );
  /// ```
  ///
  /// Throws an [Exception] if the specified module is not found.
  @visibleForTesting
  static void replaceFromModule<TModule extends EasyModule, TInstance extends Object>(
    TInstance instance, {
    String? key,
  }) {
    final module = _modules[TModule] as TModule?;
    if (module == null) {
      throw Exception('No $TModule registered');
    }
    module.injector!.replace<TInstance>(instance, key: key);
  }
}

/// A singleton class responsible for initializing and managing modules.
///
/// This class handles the registration, initialization and dependency injection
/// between modules. It maintains a map of module types to module instances and
/// processes module imports to establish dependencies.
@Deprecated('Use EasyDI instead')
class ModulesManager {
  /// The singleton instance of [ModulesManager].
  static ModulesManager? _instance;

  /// The singleton instance of [ModulesManager].
  @Deprecated('Use EasyDI instead')
  static ModulesManager get instance => _instance ??= ModulesManager();

  /// Sets the singleton instance of [ModulesManager].
  ///
  /// This is used for testing purposes to set a mock instance.
  @visibleForTesting
  static set instance(ModulesManager value) => _instance = value;

  /// Resets the singleton instance of [ModulesManager].
  ///
  /// This is used for testing purposes to reset the instance.
  @visibleForTesting
  static void reset() => _instance = null;

  @visibleForTesting
  ModulesManager() {
    EasyDI.reset();
  }

  @visibleForTesting
  UnmodifiableMapView<Type, EasyModule> get modules => EasyDI.modules;

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
  @Deprecated('Use EasyDI.initModules instead')
  Future<void> initModules(List<Module> modules) async => EasyDI.initModules(modules);

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
  @Deprecated('Use EasyDI.registerModules instead')
  void registerModule(EasyModule module) => EasyDI.registerModules([module]);

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
  @Deprecated('Use EasyDI.registerModules instead')
  void registerModules(List<EasyModule> modules) => EasyDI.registerModules(modules);

  /// ### Initializes all registered modules and processes their imports.
  ///
  /// This method must be called after all modules are added and before
  /// they are used.
  @Deprecated('Use EasyDI.initRegisteredModules instead')
  Future<void> initRegisteredModules() => EasyDI.initRegisteredModules();

  /// ### Gets a module instance of type [T] if it exists.
  ///
  /// Returns null if the module is not found.
  /// If the module exists but its injector hasn't been committed yet,
  /// this method will commit it before returning.
  ///
  /// **Note: This method is internal and should not be used outside the module manager.**
  /// Use [Module.get] instead to retrieve dependencies.
  @internal
  @Deprecated('Use EasyDI.getModule instead')
  T? getModule<T extends EasyModule>() => EasyDI.getModule<T>();

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
  @Deprecated('Use EasyDI.disposeModule instead')
  Future<void> disposeModule<T extends EasyModule>() async => EasyDI.disposeModule<T>();

  /// ### Replaces an instance in all modules that have registered it.
  ///
  /// This method searches through all registered modules and replaces the instance
  /// in any module that has registered a dependency of type T. This is useful when
  /// you don't know which module owns the dependency, but it can be slower than
  /// [replaceFromModule] since it needs to check all modules.
  ///
  /// Example:
  /// ```dart
  /// ModulesManager.instance.replace<UserRepository>(mockUserRepository);
  /// ```
  @Deprecated('Use EasyDI.replace instead')
  void replace<T extends Object>(T instance, {String? key}) => EasyDI.replace<T>(instance, key: key);

  /// ### Replaces an instance in a specific module.
  ///
  /// This method directly replaces an instance in the specified module's injector.
  /// It is faster than [replace] since it targets a specific module rather than
  /// searching through all modules.
  ///
  /// Example:
  /// ```dart
  /// ModulesManager.instance.replaceFromModule<AuthModule, UserRepository>(
  ///   mockUserRepository,
  /// );
  /// ```
  ///
  /// Throws an [Exception] if the specified module is not found.
  @visibleForTesting
  @Deprecated('Use EasyDI.replaceFromModule instead')
  void replaceFromModule<TModule extends EasyModule, TInstance extends Object>(
    TInstance instance, {
    String? key,
  }) =>
      EasyDI.replaceFromModule<TModule, TInstance>(instance, key: key);

  /// ### Disposes all registered modules.
  ///
  /// This method disposes all registered modules and clears the internal modules map.
  /// After disposing, it will:
  /// 1. Reset the module's state and injector
  /// 2. Re-process its imports to ensure dependencies are properly linked
  @visibleForTesting
  @Deprecated('Use EasyDI.reset instead')
  void dispose() => EasyDI.reset();
}
