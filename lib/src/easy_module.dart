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
import 'package:flutter/widgets.dart';
import 'package:flutter_easy_di/flutter_easy_di.dart';
import 'package:flutter_easy_di/logger.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'easy_module_widget.dart';

@Deprecated('Use EasyModule instead')
abstract class Module extends EasyModule {
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
  @Deprecated('Use EasyDI.get instead')
  static T get<T extends Object>(BuildContext context, {bool listen = false}) =>
      EasyDI.get<T>(context, listen: listen);

  /// Gets the current [EasyModule] instance from the widget tree.
  ///
  /// This method searches up the widget tree for a [EasyModuleInheritedWidget] and returns
  /// its associated module. If no module is found, returns null.
  ///
  /// Parameters:
  /// - [context]: The build context used to find the module in the widget tree
  /// - [listen]: Whether to register the calling widget for module updates.
  ///   If true, the widget will rebuild when the module changes.
  ///   Defaults to false.
  ///
  /// Returns:
  /// - The closest [EasyModule] instance in the widget tree, or null if none is found.
  ///
  /// Example:
  /// ```dart
  /// final currentModule = Module.of(context);
  /// if (currentModule != null) {
  ///   // Use the module
  /// }
  /// ```
  @Deprecated('Use EasyDI.of instead')
  static Module? of(BuildContext context, {bool listen = false}) {
    return EasyModuleInheritedWidget.of(context, listen: listen)?.module as Module?;
  }

  /// Disposes a specific singleton of type [T] from the module.
  ///
  /// This method allows you to dispose of a single dependency instead of the entire module.
  /// It will remove the dependency from the injector and call its dispose method if it's disposable.
  ///
  /// Example:
  /// ```dart
  /// Module.disposeSingleton<MyService>(context);
  /// ```
  @Deprecated('Use EasyModule.disposeSingleton instead')
  static T? disposeSingleton<T extends Object>(BuildContext context) =>
      EasyModule.disposeSingleton<T>(context);
}

/// A module is a class that contains the dependencies of a feature.
///
/// It can be used to register dependencies, imports, and other configurations.
/// Each module represents a self-contained feature or component of the application.
///
/// Example:
/// ```dart
/// class MyFeatureModule extends Module {
///   @override
///   List<Type> imports = [CoreModule];
///
///   @override
///   Future<void> registerBinds(InjectorRegister i) async {
///     i.addSingleton<MyService>(() => MyServiceImpl());
///     i.add<MyRepository>(() => MyRepositoryImpl());
///   }
/// }
/// ```
abstract class EasyModule extends ChangeNotifier {
  /// Registers dependencies for this module using the provided [InjectorRegister].
  ///
  /// This method should be implemented to define all dependencies that belong to
  /// this module.
  @visibleForOverriding
  FutureOr<void> registerBinds(InjectorRegister i);

  /// The dependency injector for this module.
  ///
  /// This is initialized during [init] and used to manage the module's
  /// dependencies.
  @visibleForTesting
  CustomAutoInjector? injector;

  /// List of other module types that this module depends on.
  ///
  /// These modules will be initialized before this module and their dependencies
  /// will be available to this module.
  @mustBeOverridden
  List<Type> get imports => [];

  /// Gets the current [EasyModule] instance from the widget tree.
  ///
  /// This method searches up the widget tree for a [EasyModuleInheritedWidget] and returns
  /// its associated module. If no module is found, returns null.
  ///
  /// Parameters:
  /// - [context]: The build context used to find the module in the widget tree
  /// - [listen]: Whether to register the calling widget for module updates.
  ///   If true, the widget will rebuild when the module changes.
  ///   Defaults to false.
  ///
  /// Returns:
  /// - The closest [EasyModule] instance in the widget tree, or null if none is found.
  ///
  /// Example:
  /// ```dart
  /// final currentModule = Module.of(context);
  /// if (currentModule != null) {
  ///   // Use the module
  /// }
  /// ```
  static EasyModule? of(BuildContext context, {bool listen = false}) {
    return EasyModuleInheritedWidget.of(context, listen: listen)?.module;
  }

  /// Initializes the module by creating an injector and registering dependencies.
  ///
  /// Returns the created [CustomAutoInjector] instance.
  Future<CustomAutoInjector> init() async {
    Logger.log('$runtimeType init!');
    validateImports();
    injector = CustomAutoInjector();
    await registerBinds(injector!);
    return injector!;
  }

  /// Disposes of the module and its dependencies.
  ///
  /// Optionally accepts a callback that will be called for each disposed instance.
  @override
  void dispose([void Function(dynamic)? instanceCallback]) {
    injector?.dispose(instanceCallback);
    Logger.log('$runtimeType disposed!');
    super.dispose();
  }

  /// Resets the module by disposing of its dependencies and reinitializing it.
  ///
  /// Optionally accepts a callback that will be called for each disposed instance.
  ///
  /// This method is useful for testing or when you need to reset the module's state.
  ///
  /// Example:
  /// ```dart
  /// await module.reset((instance) {
  ///   // Custom cleanup logic for each disposed instance
  /// });
  /// ```
  Future<void> reset([void Function(dynamic)? instanceCallback]) async {
    injector?.dispose(instanceCallback);
    injector = null;
    await init();
    Logger.log('[$EasyModule] Reset $runtimeType');
  }

  /// Disposes a specific singleton of type [T] from the module.
  ///
  /// This method allows you to dispose of a single dependency instead of the entire module.
  /// It will remove the dependency from the injector and call its dispose method if it's disposable.
  ///
  /// Example:
  /// ```dart
  /// Module.disposeSingleton<MyService>(context);
  /// ```
  static T? disposeSingleton<T extends Object>(BuildContext context) {
    final closestModule = EasyModuleInheritedWidget.of(context, listen: false)?.module;
    if (closestModule == null) {
      throw Exception('No $EasyModule found in the widget tree');
    }
    if (closestModule.injector == null) {
      throw Exception('$EasyModule ${closestModule.runtimeType} is not initialized');
    }
    try {
      return closestModule.injector!.disposeSingleton<T>();
    } catch (e) {
      throw Exception('Failed to dispose type $T in module ${closestModule.runtimeType}: $e');
    }
  }

  @visibleForTesting
  @protected
  void validateImports() {
    if (imports.contains(runtimeType)) {
      throw Exception('$EasyModule "$runtimeType" cannot import itself');
    }

    final duplicates = imports.toSet().length != imports.length;
    if (duplicates) {
      throw Exception('Duplicate imports detected in $runtimeType');
    }
  }

  /// Checks if this module imports another module.
  ///
  /// Returns true if this module imports the given [module], false otherwise.
  /// This method checks the internal dependency graph to determine if there is
  /// a direct import relationship between the modules.
  ///
  /// Example:
  /// ```dart
  /// final coreModule = CoreModule();
  /// final userModule = UserModule();
  ///
  /// // Assuming UserModule imports CoreModule
  /// print(userModule.importsModule(coreModule)); // true
  /// print(coreModule.importsModule(userModule)); // false
  /// ```
  ///
  /// Returns false if this module's injector is not initialized.
  bool importsModule(EasyModule module) {
    final injector = this.injector;
    if (injector == null) return false;
    // ignore: invalid_use_of_visible_for_testing_member
    return injector.injectorsList.contains(module.injector);
  }
}

/// Interface for registering dependencies in a module.
///
/// Provides methods for adding different types of dependencies:
/// - Regular dependencies (created new each time)
/// - Singletons (created once and reused)
/// - Lazy singletons (created on first use)
/// - Instances (pre-created objects)
abstract interface class InjectorRegister {
  /// Adds a dependency that will be created new each time it's requested.
  void add<T>(Function constructor, {String? key});

  /// Adds a singleton dependency that will be created once and reused.
  void addSingleton<T>(Function constructor, {String? key});

  /// Adds a lazy singleton that will be created on first use and then reused.
  void addLazySingleton<T>(Function constructor, {String? key});

  /// Adds a pre-created instance as a dependency.
  void addInstance<T>(T instance, {String? key});

  /// Replaces an existing dependency with a new instance.
  void replace<T>(T instance, {String? key});

  /// Commits all registered dependencies, making them available for use.
  void commit();
}

/// Custom implementation of [AutoInjectorImpl] that adds replacement functionality.
///
/// Uses UUID for unique tag generation to avoid conflicts between injectors.
class CustomAutoInjector extends AutoInjectorImpl implements InjectorRegister {
  final String tag;

  /// Creates a [CustomAutoInjector] with a specific tag and optional configuration.
  CustomAutoInjector.tag(this.tag, void Function(AutoInjector injector)? on) : super(tag, [], on);

  /// Creates a [CustomAutoInjector] with a random UUID tag.
  factory CustomAutoInjector([void Function(AutoInjector injector)? on]) {
    final tag = const Uuid().v4();
    return CustomAutoInjector.tag(tag, on);
  }

  @override
  // ignore: invalid_use_of_visible_for_testing_member
  void replace<T>(T instance, {String? key}) => replaceInstance(instance, key: key);
}
