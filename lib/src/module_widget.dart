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

import 'package:deivao_modules/deivao_modules.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// A widget that provides a module to its children.
///
/// This widget is used to provide a module to its children. The module is created
/// using the [T] module type and is passed to the children as an [InheritedWidget].
///
/// You can access the module using the `Module.get<T>()` method.
class ModuleWidget<T extends Module> extends StatefulWidget {
  /// The child widget that will have access to the module.
  final Widget child;
  const ModuleWidget({super.key, required this.child});

  @override
  State<ModuleWidget<T>> createState() => _ModuleWidgetState<T>();
}

class _ModuleWidgetState<T extends Module> extends State<ModuleWidget<T>> {
  Module? module;

  @override
  void initState() {
    super.initState();
    debugPrint('[ModuleWidget] Init $T');
    module = ModulesManager.instance.getModule<T>();
    if (module == null) debugPrint('[ModuleWidget] Module of type $T not found');
  }

  @override
  void dispose() {
    debugPrint('[ModuleWidget] Dispose $T');
    ModulesManager.instance.disposeModule<T>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (module case Module module) {
      return ModuleInheritedWidget(
        module: module,
        child: widget.child,
      );
    }
    return widget.child;
  }
}

@internal
class ModuleInheritedWidget extends InheritedNotifier {
  final Module module;
  const ModuleInheritedWidget({
    super.key,
    required this.module,
    required super.child,
  }) : super(notifier: module);

  @override
  bool updateShouldNotify(ModuleInheritedWidget oldWidget) => false;

  static ModuleInheritedWidget? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ModuleInheritedWidget>();
}
