import 'package:example/features/core/core_module.dart';
import 'package:modular_di/modular_di.dart';

import 'data/data.dart';
import 'domain/domain.dart';
import 'ui/ui.dart';

export 'ui/screens/profile_screen.dart';

// Profile module with repository
class ProfileModule extends Module {
  @override
  List<Type> imports = [CoreModule]; // Import dependencies from CoreModule

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    // Data
    i.addLazySingleton<ProfileService>(ProfileService.new);

    // Domain
    i.addLazySingleton<ProfileRepository>(ProfileRepositoryImpl.error);

    // UI
    i.addLazySingleton<GetProfileCommand>(GetProfileCommand.new);
    i.addLazySingleton<ProfileViewModel>(ProfileViewModel.new);
  }
}
