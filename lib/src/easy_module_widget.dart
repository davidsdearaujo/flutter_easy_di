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

import 'package:flutter/material.dart';
import 'package:flutter_easy_di/flutter_easy_di.dart';
import 'package:flutter_easy_di/logger.dart';
import 'package:meta/meta.dart';

/// A mixin that does nothing.
mixin _DoNothingMixin {}

@Deprecated('Use EasyModuleWidget instead')
class ModuleWidget<T extends EasyModule> = EasyModuleWidget<T> with _DoNothingMixin;

/// A widget that provides a module to its children.
///
/// This widget is used to provide a module to its children. The module is created
/// using the [T] module type and is passed to the children as an [InheritedWidget].
///
/// You can access the module using the `Module.get<T>()` method.
class EasyModuleWidget<T extends EasyModule> extends StatefulWidget {
  /// The child widget that will have access to the module.
  final Widget child;

  /// Whether the module should be disposed when the widget is disposed.
  ///
  /// If true, the module will be disposed when the widget is disposed.
  /// If false, the module will not be disposed when the widget is disposed.
  final bool autoDispose;
  const EasyModuleWidget({super.key, required this.child, this.autoDispose = true});

  @override
  State<EasyModuleWidget<T>> createState() => _EasyModuleWidgetState<T>();
}

class _EasyModuleWidgetState<T extends EasyModule> extends State<EasyModuleWidget<T>> {
  EasyModule? module;

  @override
  void initState() {
    super.initState();
    Logger.log('[ModuleWidget] Init $T');
    module = EasyDI.getModule<T>();
    if (module == null) Logger.log('[ModuleWidget] Module of type $T not found');
  }

  @override
  void dispose() {
    if (widget.autoDispose) {
      Logger.log('[ModuleWidget] Dispose $T');
      // do not throw error if module is not found
      EasyDI.disposeModule<T>().ignore();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (module case EasyModule module) {
      return EasyModuleInheritedWidget(
        module: module,
        child: widget.child,
      );
    }
    return widget.child;
  }
}

/// An [InheritedWidget] that provides access to a [EasyModule] instance in the widget tree.
///
/// This widget is used internally by [EasyModuleWidget] to make a module available to its
/// descendants. It extends [InheritedNotifier] to support notifying descendants when
/// the module changes.
///
/// The module is stored as both a [notifier] (for change notifications) and as a
/// separate [module] field for direct access.
@internal
class EasyModuleInheritedWidget extends InheritedNotifier {
  /// The module instance being provided to descendants.
  final EasyModule module;

  /// Creates a [EasyModuleInheritedWidget].
  ///
  /// The [module] and [child] parameters must not be null.
  const EasyModuleInheritedWidget({
    super.key,
    required this.module,
    required super.child,
  }) : super(notifier: module);

  @override
  bool updateShouldNotify(EasyModuleInheritedWidget oldWidget) => false;

  /// Finds the nearest [EasyModuleInheritedWidget] ancestor in the widget tree.
  ///
  /// If [listen] is true, the widget will rebuild when the module changes.
  /// If [listen] is false, the widget will not rebuild when the module changes.
  ///
  /// Returns null if no [EasyModuleInheritedWidget] is found.
  @internal
  static EasyModuleInheritedWidget? of(BuildContext context, {required bool listen}) => listen
      ? context.dependOnInheritedWidgetOfExactType<EasyModuleInheritedWidget>()
      : context.getInheritedWidgetOfExactType<EasyModuleInheritedWidget>();
}
