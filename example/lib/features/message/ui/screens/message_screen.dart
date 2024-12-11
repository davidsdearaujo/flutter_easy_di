import 'package:example/architecture.dart';
import 'package:example/features/core/core_module.dart';
import 'package:flutter/material.dart';
import 'package:modular_di/modular_di.dart';

import '../view_models/message_view_model.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> with ViewModelStateMixin<MessageViewModel> {
  @override
  void deactivate() {
    Module.disposeSingleton<MessageViewModel>(context);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message')),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            tooltip: 'Profile',
            heroTag: 'profile',
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
            child: const Icon(Icons.person),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            tooltip: 'Dispose $CoreModule',
            heroTag: 'dispose-core-module',
            onPressed: () => ModulesManager.instance.disposeModule<CoreModule>(),
            child: const Icon(Icons.delete_forever),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => viewModel.loadMessage(),
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: switch (viewModel) {
        MessageViewModel vm when vm.loading => const Center(child: CircularProgressIndicator()),
        MessageViewModel vm when vm.errors.isNotEmpty => Center(child: Text(vm.errors.join('\n'))),
        MessageViewModel vm when vm.message != null => Center(child: Text(vm.message!)),
        _ => const Center(child: Text('Tap on the button to see the message...')),
      },
    );
  }
}
