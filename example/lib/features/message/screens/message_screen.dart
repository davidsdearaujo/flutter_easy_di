import 'package:deivao_modules/deivao_modules.dart';
import 'package:example/features/core/core_module.dart';
import 'package:flutter/material.dart';

import '../view_models/message_view_model.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late MessageViewModel messageViewModel;
  @override
  void didChangeDependencies() {
    messageViewModel = Module.get<MessageViewModel>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    messageViewModel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message')),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            tooltip: 'Dispose $CoreModule',
            heroTag: 'dispose-core-module',
            onPressed: () => ModulesManager.instance.disposeModule<CoreModule>(),
            child: const Icon(Icons.delete_forever),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => messageViewModel.loadMessage(),
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: messageViewModel,
        builder: (context, child) {
          if (messageViewModel.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (messageViewModel.errors.isNotEmpty) {
            return Center(child: Text(messageViewModel.errors.join('\n')));
          }
          return Center(
            child: Text(messageViewModel.message ?? 'Tap on the button to see the message...'),
          );
        },
      ),
    );
  }
}
