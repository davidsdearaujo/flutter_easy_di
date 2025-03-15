import 'package:example/features/core/core_module.dart';
import 'package:flutter_easy_di/flutter_easy_di.dart';

import 'data/data.dart';

export 'ui/screens/profile_screen.dart';

// Profile module with repository
class ProfileModule extends EasyModule {
  @override
  List<Type> imports = [CoreModule]; // Import dependencies from CoreModule

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    i.addLazySingleton<ProfileService>(ProfileService.new);
    i.addLazySingleton<ProfileRepository>(ProfileRepositoryImpl.error);
  }
}
