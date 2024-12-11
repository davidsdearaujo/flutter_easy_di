import 'package:deivao_modules/deivao_modules.dart';
import 'package:example/features/core/core_module.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dispose-core-module',
        onPressed: () async {
          await ModulesManager.instance.disposeModule<CoreModule>();
        },
        tooltip: 'Dispose $CoreModule',
        child: const Icon(Icons.delete_forever),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Message'),
            onTap: () => Navigator.pushNamed(context, '/message'),
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }
}
