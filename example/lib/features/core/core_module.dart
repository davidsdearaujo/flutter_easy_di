import 'package:flutter_easy_di/flutter_easy_di.dart';

import 'adapters/http_client.dart';

export 'adapters/http_client.dart';

class CoreModule extends EasyModule {
  @override
  List<Type> imports = [];

  @override
  Future<void> registerBinds(InjectorRegister i) async {
    i.addLazySingleton<HttpClient>(HttpClientImpl.cached);
  }
}
