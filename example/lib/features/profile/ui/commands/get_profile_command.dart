import 'package:example/architecture.dart';
import 'package:meta/meta.dart';

import '../../domain/domain.dart';

class GetProfileCommand extends Command<ProfileModel> {
  final ProfileRepository profileRepository;
  GetProfileCommand(this.profileRepository);

  @override
  @protected
  Future<ProfileModel> execution() => profileRepository.getProfile();
}
