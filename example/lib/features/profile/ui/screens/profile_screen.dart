import 'package:flutter/material.dart';
import 'package:modular_di/modular_di.dart';

import '../view_models/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileViewModel? _profileViewModel;
  ProfileViewModel get profileViewModel => _profileViewModel!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileViewModel ??= Module.get<ProfileViewModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      floatingActionButton: FloatingActionButton(
        onPressed: profileViewModel.getProfile,
        child: const Icon(Icons.refresh),
      ),
      body: ListenableBuilder(
        listenable: profileViewModel,
        builder: (context, child) {
          if (profileViewModel.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (profileViewModel.errors.isNotEmpty) {
            return Center(child: Text('Error: ${profileViewModel.errors.join(', ')}'));
          }
          if (profileViewModel.profile == null) {
            return const Center(child: Text('Tap the button to load the profile'));
          }

          final profile = profileViewModel.profile!;
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
}
