import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/dosya_cache.json');
  }

  static Future<void> veriyiKaydet(Map<String, List<String>> veri) async {
    final file = await _localFile;
    await file.writeAsString(jsonEncode(veri));
  }

  static Future<Map<String, List<String>>?> veriyiOku() async {
    try {
      final file = await _localFile;
      if (!(await file.exists())) return null;
      final contents = await file.readAsString();
      return (jsonDecode(contents) as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, List<String>.from(value)));
    } catch (e) {
      return null;
    }
  }
}