import 'package:example/architecture.dart';

import '../../domain/domain.dart';
import '../commands/get_profile_command.dart';

class ProfileViewModel extends ViewModel {
  final GetProfileCommand getProfileCommand;
  ProfileViewModel(this.getProfileCommand);

  @override
  List<Command> get allCommands => [getProfileCommand];

  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  Future<void> getProfile() async {
    _profile = await getProfileCommand.execute();
  }
}
