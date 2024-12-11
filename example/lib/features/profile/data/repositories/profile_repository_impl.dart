import 'package:flutter/foundation.dart';

import '../../domain/domain.dart';
import '../services/profile_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService profileService;
  final bool isCacheEnabled;

  ProfileRepositoryImpl.cached(this.profileService) : isCacheEnabled = true;
  ProfileRepositoryImpl.noCache(this.profileService) : isCacheEnabled = false;

  ProfileModel? _cachedProfile;

  @override
  Future<ProfileModel> getProfile() async {
    if (isCacheEnabled && _cachedProfile != null) {
      throw 'You have already fetched the profile';
      debugPrint('$ProfileRepositoryImpl: returning cached profile');
      return _cachedProfile!;
    }

    final profile = await profileService.getProfile();
    if (isCacheEnabled) {
      _cachedProfile = profile;
    }

    return profile;
  }
}
