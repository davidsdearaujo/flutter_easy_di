import 'package:example/injection_container.dart';
import 'package:flutter/material.dart';

import '../stores/message_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final messageStore = injector.get<MessageStore>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => messageStore.getMessage(),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: messageStore,
        builder: (context, value, child) => Center(
          child: Text(value ?? 'Tap on the button to see the message...'),
        ),
      ),
    );
  }
}
