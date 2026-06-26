import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart'; 
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
  // Arama yapıldığında orijinal listeyi kaybetmemek için iki liste tutuyoruz
  late List<File> _orijinalDosyalar;
  late List<File> _aktifDosyalar;
  
  bool _aramaModu = false;
  final TextEditingController _aramaController = TextEditingController();

  @override
  void initState() 
  {
    super.initState();
    _orijinalDosyalar = List.from(widget.dosyalar);
    _aktifDosyalar = List.from(widget.dosyalar);
  }

  // CANLI ARAMA MOTORU
  void _aramaYap(String kelime) 
  {
    setState(() 
    {
      if (kelime.isEmpty) 
      {
        _aktifDosyalar = List.from(_orijinalDosyalar);
      } 
      else 
      {
        _aktifDosyalar = _orijinalDosyalar.where((dosya) 
        {
          String dosyaAdi = dosya.path.split('/').last.toLowerCase();
          return dosyaAdi.contains(kelime.toLowerCase());
        }).toList();
      }
    });
  }

  // SIRALAMA MOTORU
  void _siralamaYap(String kriter) 
  {
    setState(() 
    {
      if (kriter == 'a-z') 
      {
        _aktifDosyalar.sort((a, b) => a.path.split('/').last.toLowerCase().compareTo(b.path.split('/').last.toLowerCase()));
      } 
      else if (kriter == 'z-a') 
      {
        _aktifDosyalar.sort((a, b) => b.path.split('/').last.toLowerCase().compareTo(a.path.split('/').last.toLowerCase()));
      } 
      else if (kriter == 'boyut') 
      {
        // Büyükten küçüğe sıralama
        _aktifDosyalar.sort((a, b) => b.lengthSync().compareTo(a.lengthSync()));
      }
    });
  }

  Icon _ikonSec(String uzanti) 
  {
    switch (uzanti) 
    {
      case 'pdf': return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32);
      case 'docx':
      case 'doc': return const Icon(Icons.description, color: Colors.blue, size: 32);
      case 'xlsx':
      case 'xls': return const Icon(Icons.table_chart, color: Colors.green, size: 32);
      case 'jpg':
      case 'png':
      case 'jpeg': return const Icon(Icons.image, color: Colors.orange, size: 32);
      case 'mp4':
      case 'mkv': return const Icon(Icons.play_circle_fill, color: Colors.purple, size: 32);
      default: return const Icon(Icons.insert_drive_file, color: Colors.blueGrey, size: 32);
    }
  }

  void _dosyayiPaylas(File dosya) 
  {
    Share.shareXFiles([XFile(dosya.path)], text: 'Bu dosyaya göz at!');
  }

  void _dosyaSil(File dosya, int index) 
  {
    try 
    {
      dosya.deleteSync();
      setState(() 
      {
        _aktifDosyalar.removeAt(index);
        _orijinalDosyalar.removeWhere((d) => d.path == dosya.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dosya silindi.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    } 
    catch (e) 
    {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hata oluştu.')));
    }
  }

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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton
            (
              onPressed: () 
              {
                String yeniAd = controller.text.trim();
                if (yeniAd.isNotEmpty) 
                {
                  try 
                  {
                    String yeniYol = "${dosya.parent.path}/$yeniAd.$uzanti";
                    File yeniDosya = dosya.renameSync(yeniYol);
                    setState(() 
                    {
                      _aktifDosyalar[index] = yeniDosya;
                      // Orijinal listede de güncelliyoruz ki arama yapınca eski ad çıkmasın
                      int orijinalIndex = _orijinalDosyalar.indexWhere((d) => d.path == dosya.path);
                      if (orijinalIndex != -1) _orijinalDosyalar[orijinalIndex] = yeniDosya;
                    });
                    Navigator.pop(context);
                  } 
                  catch (e) 
                  {
                    Navigator.pop(context);
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
        // Arama moduna göre AppBar içeriğini değiştiriyoruz
        title: _aramaModu
            ? TextField
              (
                controller: _aramaController,
                autofocus: true, // Açılır açılmaz klavyeyi getirir
                decoration: const InputDecoration
                (
                  hintText: 'Dosya ara...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 18),
                onChanged: _aramaYap, // Kullanıcı her harf girdiğinde listeyi süzer
              )
            : Text(widget.baslik, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: 
        [
          // ARAMA BUTONU
          IconButton
          (
            icon: Icon(_aramaModu ? Icons.close : Icons.search),
            onPressed: () 
            {
              setState(() 
              {
                _aramaModu = !_aramaModu;
                if (!_aramaModu) 
                {
                  // Arama kapatıldığında listeyi sıfırla
                  _aramaController.clear();
                  _aramaYap('');
                }
              });
            },
          ),
          
          // SIRALAMA BUTONU
          PopupMenuButton<String>
          (
            icon: const Icon(Icons.sort),
            onSelected: _siralamaYap,
            itemBuilder: (context) => 
            [
              const PopupMenuItem(value: 'a-z', child: Text('İsme Göre (A-Z)')),
              const PopupMenuItem(value: 'z-a', child: Text('İsme Göre (Z-A)')),
              const PopupMenuItem(value: 'boyut', child: Text('En Büyük Dosyalar')),
            ],
          ),
        ],
      ),
      body: _aktifDosyalar.isEmpty
          ? const Center
            (
              child: Text("Dosya bulunamadı.", style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                    title: Text(dosyaAdi, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text("${boyutMB.toStringAsFixed(2)} MB"),
                    onTap: () => FileOpenerService.dosyayiAc(context, dosya.path, dosyaAdi),
                    trailing: PopupMenuButton<String>
                    (
                      onSelected: (deger) 
                      {
                        if (deger == 'paylas') _dosyayiPaylas(dosya);
                        else if (deger == 'adlandir') _dosyaYenidenAdlandir(dosya, index);
                        else if (deger == 'sil') _dosyaSil(dosya, index);
                      },
                      itemBuilder: (context) => 
                      [
                        const PopupMenuItem(value: 'paylas', child: Row(children: [Icon(Icons.share, color: Colors.blue, size: 20), SizedBox(width: 10), Text('Paylaş')])),
                        const PopupMenuItem(value: 'adlandir', child: Row(children: [Icon(Icons.edit, color: Colors.orange, size: 20), SizedBox(width: 10), Text('Yeniden Adlandır')])),
                        const PopupMenuItem(value: 'sil', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 10), Text('Sil')])),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}