import 'package:dosya_yoneticisi/services/cache_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'screens/dosya_listesi_ekrani.dart';
import 'widgets/kategori_karti.dart';
import 'services/file_service.dart';
import 'services/permission_service.dart';
import 'widgets/depolama_grafigi.dart';
import 'services/recent_files_service.dart';
import 'services/file_opener_service.dart';
import '/screens/klasor_tarayici_ekrani.dart';
import '/services/cache_service.dart';

void main()
{
  runApp(const DosyaYoneticisiApp());
}

class DosyaYoneticisiApp extends StatelessWidget
{
  const DosyaYoneticisiApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dosyalarım',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const AnaEkran(),
    );
  }
}

class AnaEkran extends StatefulWidget
{
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran>
{
  Map<String, List<File>>? _veriler;
  bool _izinReddedildi = false;
  List<File> _sonDosyalar = [];

  @override
  void initState()
  {
    super.initState();
    _sonDosyalariYukle();
    _baslatmaSureci();
  }

  Future<void> _sonDosyalariYukle() async
  {
    var dosyalar = await RecentFilesService.dosyalariGetir();

    setState(() {
      _sonDosyalar = dosyalar;
    });
  }

  Future<void> _baslatmaSureci() async {
    // Cache'den oku
    var cache = await CacheService.veriyiOku();
    if (cache != null) {
      setState(() {
        _veriler = {
          'Belgeler': cache['Belgeler']!.map((p) => File(p)).toList(),
          'Gorseller': cache['Gorseller']!.map((p) => File(p)).toList(),
          'Videolar': cache['Videolar']!.map((p) => File(p)).toList(),
        };
      });
    }

    // Gerçek taramayı yap
    bool izinVerildiMi = await PermissionService.depolamaIzniniIste();
    if (izinVerildiMi) {
      var yeniVeriler = await FileService.dosyalariTara();
      // Cache'e kaydet
      Map<String, List<String>> kaydedilecekVeri = {
        'Belgeler': yeniVeriler['Belgeler']!.map((f) => f.path).toList(),
        'Gorseller': yeniVeriler['Gorseller']!.map((f) => f.path).toList(),
        'Videolar': yeniVeriler['Videolar']!.map((f) => f.path).toList(),
      };
      await CacheService.veriyiKaydet(kaydedilecekVeri);

      setState(() {
        _veriler = yeniVeriler;
      });
    } else {
      setState(() {
        _izinReddedildi = true;
      });
    }
  }

  @override
  Widget build(BuildContext context)
  {
    if (_izinReddedildi) {
      return const Scaffold(body: Center(child: Text("Depolama izni gerekli!")));
    }

    if (_veriler == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dosyalarım',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _izinReddedildi
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Uygulamayı kullanabilmek için depolama izni vermelisiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            )
          : _veriler == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Veriler yükleniyor..."),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // 1. Son Kullanılanlar
                      if (_sonDosyalar.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Text("Son Kullanılanlar", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _sonDosyalar.length,
                                itemBuilder: (context, i) {
                                  String dosyaAdi = _sonDosyalar[i].path.split('/').last;
                                  return Container(
                                    width: 80,
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    child: InkWell(
                                      onTap: () => FileOpenerService.dosyayiAc(context, _sonDosyalar[i].path, dosyaAdi),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.description, size: 40, color: Colors.blueGrey),
                                          Text(dosyaAdi, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                      // 2. Depolama Çubuğu
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: LinearProgressIndicator(
                          value: 0.56,
                          minHeight: 6,
                          backgroundColor: Colors.black12,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                        ),
                      ),

                      // 3. Grafik
                      DepolamaGrafigi(
                        belgeSayisi: _veriler!['Belgeler']?.length ?? 0,
                        gorselSayisi: _veriler!['Gorseller']?.length ?? 0,
                        videoSayisi: _veriler!['Videolar']?.length ?? 0,
                      ),

                      // 4. Kategori Kartları
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(16),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          KategoriKarti(baslik: 'Belgeler', ikon: Icons.description, renk: Colors.blue, dosyaSayisi: _veriler!['Belgeler']?.length ?? 0, onClick: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DosyaListesiEkrani(baslik: 'Belgeler', dosyalar: _veriler!['Belgeler'] ?? [], mevcutDizin: '/storage/emulated/0/Documents')))),
                          KategoriKarti(baslik: 'Görseller', ikon: Icons.image, renk: Colors.orange, dosyaSayisi: _veriler!['Gorseller']?.length ?? 0, onClick: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DosyaListesiEkrani(baslik: 'Görseller', dosyalar: _veriler!['Gorseller'] ?? [], mevcutDizin: '/storage/emulated/0/Pictures')))),
                          KategoriKarti(baslik: 'Videolar', ikon: Icons.play_circle_fill, renk: Colors.red, dosyaSayisi: _veriler!['Videolar']?.length ?? 0, onClick: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DosyaListesiEkrani(baslik: 'Videolar', dosyalar: _veriler!['Videolar'] ?? [], mevcutDizin: '/storage/emulated/0/Movies')))),
                          KategoriKarti(baslik: 'Tüm Dosyalar', ikon: Icons.folder_open, renk: Colors.purple, dosyaSayisi: -1, onClick: () => Navigator.push(context, MaterialPageRoute(builder: (context) => KlasorTarayiciEkrani(dizin: Directory('/storage/emulated/0/'))))),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}