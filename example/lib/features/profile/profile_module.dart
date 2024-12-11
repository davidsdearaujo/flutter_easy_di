import 'package:example/features/core/core_module.dart';
import 'package:modular_di/modular_di.dart';

import 'data/data.dart';

export 'ui/screens/profile_screen.dart';

// Profile module with repository
class ProfileModule extends Module {
  @override
  List<Type> imports = [CoreModule]; // Import dependencies from CoreModule

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    i.addLazySingleton<ProfileService>(ProfileService.new);
    i.addLazySingleton<ProfileRepository>(ProfileRepositoryImpl.error);
  }
}
