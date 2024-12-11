import 'package:example/features/core/core_module.dart';
import 'package:modular_di/modular_di.dart';

export 'screens/message_screen.dart';

class MessageModule extends Module {
  @override
  List<Type> imports = [CoreModule];

  @override
  Future<void> registerBinds(InjectorRegister i) async {}
}
