import 'package:flutter/material.dart';
import 'package:modular_di/modular_di.dart';

import '../../data/data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<ProfileModel>? _profileFuture;
  late ProfileRepository _profileRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileRepository = Module.get<ProfileRepository>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadProfile,
        child: const Icon(Icons.refresh),
      ),
      body: FutureBuilder(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data == null) {
            return const Center(child: Text('Tap the button to load the profile'));
          }

          final profile = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${profile.name}'),
                const SizedBox(height: 10),
                Text('Age: ${profile.age}'),
                const SizedBox(height: 10),
                Text('Url: ${profile.profileUrl}'),
              ],
            ),
          );
        },
      ),
    );
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = _profileRepository.getProfile();
    });
  }
}
