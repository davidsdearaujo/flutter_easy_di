import 'package:flutter_easy_di/flutter_easy_di.dart';

export 'screens/home_screen.dart';

class HomeModule extends EasyModule {
  @override
  List<Type> imports = [];

  @override
  Future<void> registerBinds(InjectorRegister i) async {}
}
