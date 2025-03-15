import 'package:example/features/core/core_module.dart';
import 'package:flutter_easy_di/flutter_easy_di.dart';

export 'screens/message_screen.dart';

class MessageModule extends EasyModule {
  @override
  List<Type> imports = [CoreModule];

  @override
  Future<void> registerBinds(InjectorRegister i) async {}
}
