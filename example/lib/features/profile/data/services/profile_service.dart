import 'dart:convert';

import 'package:example/features/core/core_module.dart';

import '../models/profile_model.dart';

/// Profile service
class ProfileService {
  final HttpClient httpClient;
  const ProfileService(this.httpClient);

  /// Get profile from the server
  Future<ProfileModel> getProfile() async {
    final json = await httpClient.get('https://api.example.com/profile');
    final map = jsonDecode(json);
    return ProfileModel.fromMap(map);
  }
}
