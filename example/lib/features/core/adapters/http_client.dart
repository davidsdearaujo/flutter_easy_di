import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';

abstract class HttpClient {
  Future<String> get(String url);
}

class HttpClientImpl implements HttpClient {
  final bool isCacheEnabled;
  final HttpCache _cache;
  HttpClientImpl._({required this.isCacheEnabled}) : _cache = HttpCache(isCacheEnabled);
  factory HttpClientImpl.cached() => HttpClientImpl._(isCacheEnabled: true);
  factory HttpClientImpl.noCache() => HttpClientImpl._(isCacheEnabled: false);

  @override
  Future<String> get(String url) async {
    if (_cache[url] case String cached) {
      debugPrint('$HttpClientImpl: returning cached response for $url');
      return cached;
    }
    await Future.delayed(const Duration(seconds: 1));
    final response = switch (url) {
      'https://api.example.com/profile' => jsonEncode({"name": "John", "age": 30, "url": url}),
      'https://api.example.com/message' => "Hello from $url",
      _ => "Unknown url: $url",
    };
    _cache[url] = response;
    return response;
  }
}

/// Cache for the HTTP requests
///
/// ### Attention
/// This cache logic is just to understand when the CoreModule is still alive;
///
/// The right place to cache the data is in the repository from each feature module.
class HttpCache with MapMixin<String, String> {
  final _cache = <String, String>{};
  final bool _isCacheEnabled;
  HttpCache(this._isCacheEnabled);

  @override
  String? operator [](Object? key) {
    if (!_isCacheEnabled) return null;
    return _cache[key];
  }

  @override
  void operator []=(String key, String value) {
    if (!_isCacheEnabled) return;
    _cache[key] = value;
  }

  @override
  void clear() {
    if (!_isCacheEnabled) return;
    _cache.clear();
  }

  @override
  Iterable<String> get keys {
    if (!_isCacheEnabled) return [];
    return _cache.keys;
  }

  @override
  String? remove(Object? key) {
    if (!_isCacheEnabled) return null;
    return _cache.remove(key);
  }
}
