part of 'architecture.dart';

abstract class ViewModel extends ChangeNotifier {
  ViewModel() {
    for (final command in allCommands) {
      command.addListener(notifyListeners);
    }
  }

  List<Command> get allCommands;

  bool get loading => allCommands.any((command) => command.loading);
  List<Object> get errors => allCommands //
      .map((command) => command.error?.exception)
      .whereType<Object>()
      .toList();

  @override
  void dispose() {
    for (final command in allCommands) {
      command.dispose();
    }
    super.dispose();
  }
}
