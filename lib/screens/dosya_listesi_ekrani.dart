import 'package:flutter/material.dart';
import 'dart:io';
import '../services/file_opener_service.dart';

class DosyaListesiEkrani extends StatelessWidget 
{
  final String baslik;
  final List<File> dosyalar;

  const DosyaListesiEkrani
  (
    {
    super.key,
    required this.baslik,
    required this.dosyalar,
    }
  );

  // Dosya uzantısına göre dinamik ikon seçen yardımcı fonksiyon
  Icon _ikonSec(String uzanti) 
  {
    switch (uzanti)
    {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32);
      case 'docx':
      case 'doc':
        return const Icon(Icons.description, color: Colors.blue, size: 32);
      case 'xlsx':
      case 'xls':
        return const Icon(Icons.table_chart, color: Colors.green, size: 32);
      case 'jpg':
      case 'png':
      case 'jpeg':
        return const Icon(Icons.image, color: Colors.orange, size: 32);
      case 'mp4':
      case 'mkv':
        return const Icon(Icons.play_circle_fill, color: Colors.purple, size: 32);
      default:
        return const Icon(Icons.insert_drive_file, color: Colors.blueGrey, size: 32);
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: dosyalar.isEmpty
          ? const Center
          (
              child: Text
              (
                "Bu kategoride dosya bulunamadı.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder
          (
              itemCount: dosyalar.length,
              itemBuilder: (context, index) 
              {
                File dosya = dosyalar[index];
                
                // Dosyanın tam yolundan sadece adını çıkarıyoruz
                String dosyaAdi = dosya.path.split('/').last;
                String uzanti = dosyaAdi.split('.').last.toLowerCase();
                
                // Bayt cinsinden gelen boyutu Megabayt'a (MB) çeviriyoruz
                double boyutMB = dosya.lengthSync() / (1024 * 1024);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile
                  (
                    leading: _ikonSec(uzanti),
                    title: Text
                    (
                      dosyaAdi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Uzun isimleri ... ile keser
                    ),
                    subtitle: Text("${boyutMB.toStringAsFixed(2)} MB"),
                    onTap: () 
                    {
                      // Yazdığımız hibrit motoru çağırıyoruz
                      FileOpenerService.dosyayiAc(context, dosya.path);
                    },
                  ),
                );
              },
            ),
    );
  }
}