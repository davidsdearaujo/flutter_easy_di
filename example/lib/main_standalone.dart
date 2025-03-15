// User module with repository and service
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easy_di/flutter_easy_di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyDI.initModules([
    CoreModule(),
    ProfileModule(),
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/profile',
      routes: {
        '/profile': (context) {
          return const EasyModuleWidget<ProfileModule>(
            child: ProfileScreen(),
          );
        },
      },
    );
  }
}

/// Core module with http client
class CoreModule extends EasyModule {
  @override
  List<Type> imports = [];

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    i.addLazySingleton<HttpClient>(HttpClientImpl.new);
  }
}

abstract class HttpClient {
  Future<String> get(String url);
}

class HttpClientImpl implements HttpClient {
  const HttpClientImpl();

  @override
  Future<String> get(String url) async {
    await Future.delayed(const Duration(seconds: 2));
    return jsonEncode({"name": "John", "age": 30, "url": url});
  }
}

// Profile module with repository
class ProfileModule extends EasyModule {
  @override
  List<Type> imports = [CoreModule]; // Import dependencies from CoreModule

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    i.addSingleton<ProfileRepository>(ProfileRepositoryImpl.new);
  }
}

abstract class ProfileRepository {
  Future<String> getProfile();
}

class ProfileRepositoryImpl implements ProfileRepository {
  final HttpClient httpClient;
  const ProfileRepositoryImpl(this.httpClient);

  @override
  Future<String> getProfile() async {
    return await httpClient.get('https://api.example.com/profile');
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map>? future;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final profileRepository = EasyDI.get<ProfileRepository>(context);
          setState(() {
            future = profileRepository //
                .getProfile()
                .then((value) => jsonDecode(value));
          });
        },
        child: const Icon(Icons.refresh),
      ),
      body: FutureBuilder<Map>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Tap the button to load the profile'));
          }

          final profile = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${profile['name']}'),
                const SizedBox(height: 10),
                Text('Age: ${profile['age']}'),
                const SizedBox(height: 10),
                Text('Url: ${profile['url']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
