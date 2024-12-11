part of 'architecture.dart';

abstract class ViewModel extends ChangeNotifier {
  ViewModel() {
    for (final command in commands) {
      command.addListener(notifyListeners);
    }
  }

  List<Command> get commands;

  bool get loading => commands.any((command) => command.loading);
  List<Object> get errors => commands //
      .map((command) => command.error?.exception)
      .whereType<Object>()
      .toList();

  @override
  void dispose() {
    for (final command in commands) {
      command.dispose();
    }
    super.dispose();
  }
}
