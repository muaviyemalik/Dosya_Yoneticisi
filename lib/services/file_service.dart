import 'dart:io';

class FileService {
  // Android cihazların standart ana depolama dizini
  static const String _anaDizin = '/storage/emulated/0/';

  // Dosyaları tarayıp kategorilerine göre gruplayan fonksiyon
  static Future<Map<String, List<File>>> dosyalariTara() async {
    // Kategorilerimizi hazırlayalım
    Map<String, List<File>> kategoriler = {
      'Belgeler': [],
      'Gorseller': [],
      'Videolar': [],
    };

    try {
      Directory dizin = Directory(_anaDizin);
      
      // Tüm cihazı alt klasörleriyle birlikte tarayalım (Stream yapısı ile)
      // handleError: Android'in kendi gizli sistem klasörlerindeki okuma hatalarını görmezden gelmemizi sağlar
      await for (var entity in dizin.list(recursive: true, followLinks: false).handleError((e) {})) {
        if (entity is File) {
          // Dosyanın uzantısını bul (örneğin: "belge.docx" -> "docx")
          String uzanti = entity.path.split('.').last.toLowerCase();

          // Uzantıya göre ilgili kategori listesine ekle
          if (['pdf', 'docx', 'doc', 'xlsx', 'xls', 'pptx', 'txt'].contains(uzanti)) {
            kategoriler['Belgeler']!.add(entity);
          } else if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(uzanti)) {
            kategoriler['Gorseller']!.add(entity);
          } else if (['mp4', 'mkv', 'avi'].contains(uzanti)) {
            kategoriler['Videolar']!.add(entity);
          }
        }
      }
    } catch (e) {
      print("Genel tarama hatası: $e");
    }

    return kategoriler;
  }
}