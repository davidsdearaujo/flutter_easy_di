import 'package:example/architecture.dart';

import '../commands/load_message_command.dart';

class MessageViewModel extends ViewModel {
  final LoadMessageCommand _loadMessageCommand;
  MessageViewModel(this._loadMessageCommand);

  @override
  List<Command> get commands => [_loadMessageCommand];

  String? _message;
  String? get message => _message;

  Future<void> loadMessage() async {
    if (_loadMessageCommand.loading) return;
    _message = await _loadMessageCommand.execute();
  }
}
