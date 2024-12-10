import 'package:flutter/foundation.dart';

import '../../core/services/core_service.dart';

class MessageStore extends ValueNotifier<String?> {
  final CoreService _coreService;
  MessageStore(this._coreService) : super(null);

  void getMessage() {
    value = _coreService.getMessage();
  }
}
