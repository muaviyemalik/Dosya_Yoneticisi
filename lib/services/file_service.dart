import 'dart:io';
import 'dart:isolate'; // Arka plan işçisi için gerekli kütüphane

class FileService 
{
  static const String _anaDizin = '/storage/emulated/0/';

  // 1. UYGULAMANIN ÇAĞIRACAĞI ANA FONKSİYON
  // Bu fonksiyon sadece arka plan işçisini işe alır ve sonucu bekler.
  static Future<Map<String, List<File>>> dosyalariTara() async 
  {
    // Isolate.run: İşletim sisteminden boşta olan bir işlemci çekirdeği ister
    // ve _arkaPlandaTara fonksiyonunu o çekirdeğe yollar.
    return await Isolate.run(_arkaPlandaTara);
  }

  // 2. ARKA PLAN İŞÇİSİNİN (ISOLATE) YAPACAĞI AĞIR İŞ
  // Bu kod ana ekranı kesinlikle dondurmaz.
  static Future<Map<String, List<File>>> _arkaPlandaTara() async 
  {
    Map<String, List<File>> kategoriler = 
    {
      'Belgeler': [],
      'Gorseller': [],
      'Videolar': [],
    };

    try 
    {
      Directory dizin = Directory(_anaDizin);
      
      await for (var entity in dizin.list(recursive: true, followLinks: false).handleError((e) {})) 
      {
        if (entity is File) 
        {
          String uzanti = entity.path.split('.').last.toLowerCase();

          if (['pdf', 'docx', 'doc', 'xlsx', 'xls', 'pptx', 'txt'].contains(uzanti)) 
          {
            kategoriler['Belgeler']!.add(entity);
          } 
          else if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(uzanti)) 
          {
            kategoriler['Gorseller']!.add(entity);
          } 
          else if (['mp4', 'mkv', 'avi'].contains(uzanti)) 
          {
            kategoriler['Videolar']!.add(entity);
          }
        }
      }
    } 
    catch (e) 
    {
      print("Genel tarama hatası: $e");
    }

    return kategoriler;
  }
}