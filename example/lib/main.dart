import 'package:flutter/material.dart';
import 'package:flutter_easy_di/flutter_easy_di.dart';
import 'package:flutter_easy_di/logger.dart';

import 'features/core/core_module.dart';
import 'features/home/home_module.dart';
import 'features/message/message_module.dart';
import 'features/profile/profile_module.dart';

/// ### All the modules that the app has. <br/>
/// It's used to initialize the dependencies. <br/><br/>
final modules = <EasyModule>[
  CoreModule(),
  MessageModule(),
  HomeModule(),
  ProfileModule(),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.enable();
  await EasyDI.initModules(modules);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const EasyModuleWidget<HomeModule>(child: HomeScreen()),
        '/message': (context) => const EasyModuleWidget<MessageModule>(child: MessageScreen()),
        '/profile': (context) => const EasyModuleWidget<ProfileModule>(child: ProfileScreen()),
      },
    );
  }
}
