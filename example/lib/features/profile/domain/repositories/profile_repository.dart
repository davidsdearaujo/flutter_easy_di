import '../models/profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileModel> getProfile();
}
