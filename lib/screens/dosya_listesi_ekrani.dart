import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart'; // Paylaşma paketi
import '../services/file_opener_service.dart';

class DosyaListesiEkrani extends StatefulWidget 
{
  final String baslik;
  final List<File> dosyalar;

  const DosyaListesiEkrani({
    super.key,
    required this.baslik,
    required this.dosyalar,
  });

  @override
  State<DosyaListesiEkrani> createState() => _DosyaListesiEkraniState();
}

class _DosyaListesiEkraniState extends State<DosyaListesiEkrani> 
{
  // Ekrandaki dosyaları manipüle edebilmek için kendi listemize alıyoruz
  late List<File> _aktifDosyalar;

  @override
  void initState() 
  {
    super.initState();
    _aktifDosyalar = List.from(widget.dosyalar);
  }

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

  // 1. YÖNETİM FONKSİYONU: PAYLAŞMA
  void _dosyayiPaylas(File dosya) 
  {
    Share.shareXFiles([XFile(dosya.path)], text: 'Bu dosyaya göz at!');
  }

  // 2. YÖNETİM FONKSİYONU: SİLME
  void _dosyaSil(File dosya, int index) 
  {
    try 
    {
      // Dosyayı cihaz hafızasından kalıcı olarak siler
      dosya.deleteSync();
      
      setState(() 
      {
        // Dosyayı ekrandaki listeden çıkartır
        _aktifDosyalar.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar
      (
        const SnackBar(content: Text('Dosya başarıyla silindi.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    } 
    catch (e) 
    {
      ScaffoldMessenger.of(context).showSnackBar
      (
        const SnackBar(content: Text('Dosya silinirken bir hata oluştu.')),
      );
    }
  }

  // 3. YÖNETİM FONKSİYONU: YENİDEN ADLANDIRMA
  void _dosyaYenidenAdlandir(File dosya, int index) 
  {
    String eskiAd = dosya.path.split('/').last;
    String uzanti = eskiAd.split('.').last;
    String sadeceAd = eskiAd.substring(0, eskiAd.lastIndexOf('.'));

    TextEditingController controller = TextEditingController(text: sadeceAd);

    showDialog
    (
      context: context,
      builder: (context) 
      {
        return AlertDialog
        (
          title: const Text('Yeniden Adlandır'),
          content: TextField
          (
            controller: controller,
            decoration: const InputDecoration(hintText: "Yeni dosya adını girin"),
          ),
          actions: 
          [
            TextButton
            (
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton
            (
              onPressed: () 
              {
                String yeniAd = controller.text.trim();
                if (yeniAd.isNotEmpty) 
                {
                  try 
                  {
                    // Dosyanın bulunduğu klasörün yolunu alıp yeni isimle birleştiriyoruz
                    String yeniYol = "${dosya.parent.path}/$yeniAd.$uzanti";
                    File yeniDosya = dosya.renameSync(yeniYol);

                    setState(() 
                    {
                      // Ekrandaki dosyayı yeni dosya ile güncelliyoruz
                      _aktifDosyalar[index] = yeniDosya;
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar
                    (
                      const SnackBar(content: Text('Dosya adı başarıyla değiştirildi.'), backgroundColor: Colors.green),
                    );
                  } 
                  catch (e) 
                  {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar
                    (
                      const SnackBar(content: Text('İsim değiştirilirken bir hata oluştu.'), backgroundColor: Colors.orange),
                    );
                  }
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text(widget.baslik, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _aktifDosyalar.isEmpty
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
              itemCount: _aktifDosyalar.length,
              itemBuilder: (context, index) 
              {
                File dosya = _aktifDosyalar[index];
                String dosyaAdi = dosya.path.split('/').last;
                String uzanti = dosyaAdi.split('.').last.toLowerCase();
                double boyutMB = dosya.lengthSync() / (1024 * 1024);

                return Card
                (
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile
                  (
                    leading: _ikonSec(uzanti),
                    title: Text
                    (
                      dosyaAdi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text("${boyutMB.toStringAsFixed(2)} MB"),
                    onTap: () 
                    {
                      FileOpenerService.dosyayiAc(context, dosya.path, dosyaAdi);
                    },
                    // SAĞ TARAFA EKLEDİĞİMİZ ÜÇ NOKTA YÖNETİM MENÜSÜ
                    trailing: PopupMenuButton<String>
                    (
                      onSelected: (deger) 
                      {
                        if (deger == 'paylas') 
                        {
                          _dosyayiPaylas(dosya);
                        } 
                        else if (deger == 'adlandir') 
                        {
                          _dosyaYenidenAdlandir(dosya, index);
                        } 
                        else if (deger == 'sil') 
                        {
                          _dosyaSil(dosya, index);
                        }
                      },
                      itemBuilder: (BuildContext context) => 
                      [
                        const PopupMenuItem
                        (
                          value: 'paylas',
                          child: Row
                          (
                            children: 
                            [
                              Icon(Icons.share, color: Colors.blue, size: 20),
                              SizedBox(width: 10),
                              Text('Paylaş'),
                            ],
                          ),
                        ),
                        const PopupMenuItem
                        (
                          value: 'adlandir',
                          child: Row
                          (
                            children: 
                            [
                              Icon(Icons.edit, color: Colors.orange, size: 20),
                              SizedBox(width: 10),
                              Text('Yeniden Adlandır'),
                            ],
                          ),
                        ),
                        const PopupMenuItem
                        (
                          value: 'sil',
                          child: Row
                          (
                            children: 
                            [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 10),
                              Text('Sil'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}