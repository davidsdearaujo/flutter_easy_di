import 'package:example/features/core/core_module.dart';
import 'package:modular_di/modular_di.dart';

import 'ui/commands/load_message_command.dart';
import 'ui/view_models/message_view_model.dart';

class MessageModule extends Module {
  @override
  List<Type> imports = [CoreModule];

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    i.add<MessageViewModel>(MessageViewModel.new);
    i.add<LoadMessageCommand>(LoadMessageCommand.new);
  }
}
