import 'package:deivao_modules/deivao_modules.dart';

export 'ui/screens/home_screen.dart';

class HomeModule extends Module {
  @override
  List<Type> imports = [];

  @override
  Future<void> registerBinds(InjectorRegister i) async {}
}
