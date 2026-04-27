import 'package:flutter/foundation.dart';
import 'config_loader.dart';

class ApiConfig {
  static String? _cachedBaseUrl;
  static bool _isInitialized = false;
  static String? _uiConfiguredUrl;

  static Future<String> getBaseUrl() async {
    if (!_isInitialized) {
      _cachedBaseUrl = await _detectBaseUrl();
      _isInitialized = true;
    }

    if (_cachedBaseUrl != null && _cachedBaseUrl!.isNotEmpty) {
      return _cachedBaseUrl!;
    }

    return '';
  }

  static Future<String?> _detectBaseUrl() async {
    final sources = <Future<String?>>[];

    sources.add(_getEnvVariable());
    sources.add(_getConfigFile());
    sources.add(_getUiConfig());

    if (kIsWeb) {
      sources.add(_getWebDefault());
    } else {
      sources.add(_getPlatformDefault());
    }

    for (final source in sources) {
      final url = await source;
      if (url != null && url.isNotEmpty) {
        return url;
      }
    }

    return null;
  }

  static Future<String?> _getEnvVariable() async {
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    return apiBaseUrl.isNotEmpty ? apiBaseUrl : null;
  }

  static Future<String?> _getConfigFile() async {
    return await ConfigLoader.loadApiUrl();
  }

  static Future<String?> _getUiConfig() async {
    return _uiConfiguredUrl;
  }

  static Future<String?> _getWebDefault() async {
    if (!kIsWeb) return null;

    try {
      final currentUri = Uri.base;
      final host = currentUri.host;

      if (host.startsWith('localhost')) {
        return 'http://localhost:8081';
      }

      // 生产环境使用相对路径（Vercel API 代理）
      return '';
    } catch (e) {
      return null;
    }
  }

  static Future<String?> _getPlatformDefault() async {
    return 'http://localhost:8081';
  }

  static void setUiConfiguredUrl(String url) {
    _uiConfiguredUrl = url;
    _isInitialized = false;
  }

  static void clearCache() {
    _isInitialized = false;
    _cachedBaseUrl = null;
  }

  static bool hasApiUrl() {
    return _cachedBaseUrl != null && _cachedBaseUrl!.isNotEmpty;
  }

  static bool isMockMode() {
    return !hasApiUrl();
  }
}