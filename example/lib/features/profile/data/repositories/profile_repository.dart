import 'package:flutter/foundation.dart';

import '../models/profile_model.dart';
import '../services/profile_service.dart';

abstract class ProfileRepository {
  Future<ProfileModel> getProfile();
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService profileService;
  final bool isCacheEnabled;
  final bool isErrorEnabled;

  ProfileRepositoryImpl.cached(this.profileService)
      : isCacheEnabled = true,
        isErrorEnabled = false;
  ProfileRepositoryImpl.noCache(this.profileService)
      : isCacheEnabled = false,
        isErrorEnabled = false;
  ProfileRepositoryImpl.error(this.profileService)
      : isCacheEnabled = true,
        isErrorEnabled = true;

  ProfileModel? _cachedProfile;

  @override
  Future<ProfileModel> getProfile() async {
    if (isCacheEnabled && _cachedProfile != null) {
      if (isErrorEnabled) {
        throw 'You have already fetched the profile';
      }
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
