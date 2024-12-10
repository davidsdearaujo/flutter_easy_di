import 'package:deivao_modules/deivao_modules.dart';

import 'services/core_service.dart';

class CoreModule extends Module {
  @override
  List<Type> imports = [];

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    i.add<CoreService>(CoreService.new);
  }
}
