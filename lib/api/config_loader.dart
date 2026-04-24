import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io' if (dart.library.html) 'stub_file.dart';

class ConfigLoader {
  static const String _configFileName = 'api_config.json';

  static Future<String?> loadApiUrl() async {
    if (kIsWeb) {
      return null;
    }

    try {
      final file = await _findConfigFile();
      if (file == null) {
        return null;
      }

      final content = await file.readAsString();
      final config = jsonDecode(content) as Map<String, dynamic>;
      return config['api_url'] as String?;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> _findConfigFile() async {
    final paths = [
      _configFileName,
      'config/$configFileName',
      'assets/$configFileName',
    ];

    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) {
        return file;
      }
    }

    return null;
  }

  static Future<void> saveApiUrl(String url) async {
    if (kIsWeb) {
      return;
    }

    try {
      final file = File(_configFileName);
      final config = {
        'api_url': url,
      };
      await file.writeAsString(jsonEncode(config));
    } catch (e) {
      print('Failed to save config: $e');
    }
  }
}