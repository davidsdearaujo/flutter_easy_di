part of 'architecture.dart';

abstract class Command<T> extends ChangeNotifier {
  final _loadingNotifier = ValueNotifier<bool>(false);
  ValueListenable<bool> get loadingNotifier => _loadingNotifier;
  bool get loading => _loadingNotifier.value;

  final _errorNotifier = ValueNotifier<Failure?>(null);
  ValueListenable<Failure?> get errorNotifier => _errorNotifier;
  Failure? get error => _errorNotifier.value;

  Command() {
    _loadingNotifier.addListener(notifyListeners);
    _errorNotifier.addListener(notifyListeners);
  }

  @protected
  Future<T> execution();

  @useResult
  Future<T> execute() async {
    try {
      _loadingNotifier.value = true;
      final state = await execution();
      return state;
    } on Failure catch (failure) {
      _errorNotifier.value = failure;
      rethrow;
    } catch (ex, stack) {
      _errorNotifier.value = Failure.unknown(ex, stack);
      rethrow;
    } finally {
      _loadingNotifier.value = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _errorNotifier.dispose();
    _loadingNotifier.dispose();
  }
}
