import 'package:example/architecture.dart';
import 'package:example/features/core/core_module.dart';
import 'package:meta/meta.dart';

class LoadMessageCommand extends Command<String> {
  final HttpClient _httpClient;
  LoadMessageCommand(this._httpClient);

  @override
  @protected
  Future<String> execution() async {
    final result = await _httpClient.get('https://api.example.com/message');
    return result;
  }
}
