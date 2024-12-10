import 'package:deivao_modules/deivao_modules.dart';
import 'package:example/features/core/core_module.dart';

import 'stores/message_store.dart';

class HomeModule extends Module {
  @override
  List<Type> imports = [CoreModule];

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    i.addLazySingleton<MessageStore>(MessageStore.new);
  }
}
