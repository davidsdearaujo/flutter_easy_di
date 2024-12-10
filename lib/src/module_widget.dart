import 'package:deivao_modules/deivao_modules.dart';
import 'package:flutter/material.dart';

/// A widget that provides a module to its children.
///
/// This widget is used to provide a module to its children. The module is created
/// using the [builder] function and is passed to the children as an [InheritedWidget].
class ModuleWidget extends StatefulWidget {
  /// The builder function that creates the module.
  final ModuleBuilder builder;

  /// The child widget that will have access to the module.
  final Widget child;
  const ModuleWidget({super.key, required this.builder, required this.child});

  @override
  State<ModuleWidget> createState() => _ModuleWidgetState();
}

class _ModuleWidgetState extends State<ModuleWidget> {
  late Module module;

  @override
  void initState() {
    super.initState();
    module = widget.builder(context);
  }

  @override
  void dispose() {
    module.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ModuleInheritedWidget(
      module: module,
      child: widget.child,
    );
  }
}

typedef ModuleBuilder = Module Function(BuildContext context);

class _ModuleInheritedWidget extends InheritedWidget {
  final Module module;
  const _ModuleInheritedWidget({
    super.key,
    required this.module,
    required super.child,
  });

  @override
  bool updateShouldNotify(_ModuleInheritedWidget oldWidget) => false;
}
