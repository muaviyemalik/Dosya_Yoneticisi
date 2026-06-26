import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class RecentFilesService 
{
  static const String _key = 'son_kullanilanlar';

  static Future<void> dosyayiEkle(String yol) async 
  {
    final prefs = await SharedPreferences.getInstance();
    List<String> liste = prefs.getStringList(_key) ?? [];

    // Eğer zaten varsa sil (en başa alacağız)
    liste.remove(yol);
    liste.insert(0, yol);

    // Sadece son 5 dosyayı tut
    if (liste.length > 5) 
    {
      liste = liste.sublist(0, 5);
    }

    await prefs.setStringList(_key, liste);
  }

  static Future<List<File>> dosyalariGetir() async 
  {
    final prefs = await SharedPreferences.getInstance();
    List<String> yollar = prefs.getStringList(_key) ?? [];
    
    return yollar.map((yol) => File(yol)).where((f) => f.existsSync()).toList();
  }
}