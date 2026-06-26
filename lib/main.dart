import 'package:flutter/material.dart';
import 'dart:io';
import 'screens/dosya_listesi_ekrani.dart';
import 'widgets/kategori_karti.dart';
import 'services/file_service.dart';
import 'services/permission_service.dart';
import 'widgets/depolama_grafigi.dart';

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
  Future<Map<String, List<File>>>? _dosyaTaramasi;
  bool _izinReddedildi = false;

  @override
  void initState()
  {
    super.initState();
    _izinVeTaramaBaslat(); 
  }

  Future<void> _izinVeTaramaBaslat() async 
  {
    bool izinVerildiMi = await PermissionService.depolamaIzniniIste();
    
    if (izinVerildiMi) 
    {
      setState(() 
      {
        _dosyaTaramasi = FileService.dosyalariTara();
      });
    } 
    else 
    {
      setState(() 
      {
        _izinReddedildi = true; 
      });
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosyalarım', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _izinReddedildi
          ? const Center(
              child: Text(
                'Uygulamayı kullanabilmek için depolama izni vermelisiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            )
          : _dosyaTaramasi == null
              ? const Center(child: CircularProgressIndicator()) 
              : FutureBuilder<Map<String, List<File>>>
              (
                  future: _dosyaTaramasi,
                  builder: (context, snapshot) 
                  {
                    if (snapshot.connectionState == ConnectionState.waiting) 
                    {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text("Cihaz taranıyor, lütfen bekleyin..."),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) 
                    {
                      return const Center(child: Text("Dosyalar okunurken bir hata oluştu."));
                    }
                    // Veriler başarıyla geldiyse grafiği ve kartları oluştur
                    final veriler = snapshot.data!;
                    int belgeAdedi = veriler['Belgeler']?.length ?? 0;
                    int gorselAdedi = veriler['Gorseller']?.length ?? 0;
                    int videoAdedi = veriler['Videolar']?.length ?? 0;
                    
                    return Column
                    (
                      children: 
                      [
                        const SizedBox(height: 20),
                        
                        // Üst Kısım: Pasta Grafiği
                        DepolamaGrafigi
                        (
                          belgeSayisi: belgeAdedi,
                          gorselSayisi: gorselAdedi,
                          videoSayisi: videoAdedi,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Alt Kısım: Kategori Kartları (Expanded ile kalan boşluğu doldurur)
                        Expanded
                        (
                          child: Padding
                          (
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: GridView.count
                            (
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              children: 
                              [
                                KategoriKarti
                                (
                                  baslik: 'Belgeler',
                                  ikon: Icons.description,
                                  renk: Colors.blue,
                                  dosyaSayisi: belgeAdedi, 
                                  onClick: () 
                                  {
                                    Navigator.push
                                    (
                                      context,
                                      MaterialPageRoute
                                      (
                                        builder: (context) => DosyaListesiEkrani
                                        (
                                          baslik: 'Belgeler',
                                          dosyalar: veriler['Belgeler'] ?? [],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                KategoriKarti
                                (
                                  baslik: 'Görseller',
                                  ikon: Icons.image,
                                  renk: Colors.orange,
                                  dosyaSayisi: gorselAdedi, 
                                  onClick: () 
                                  {
                                    Navigator.push
                                    (
                                      context,
                                      MaterialPageRoute
                                      (
                                        builder: (context) => DosyaListesiEkrani
                                        (
                                          baslik: 'Görseller',
                                          dosyalar: veriler['Gorseller'] ?? [],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                KategoriKarti
                                (
                                  baslik: 'Videolar',
                                  ikon: Icons.play_circle_fill,
                                  renk: Colors.red,
                                  dosyaSayisi: videoAdedi, 
                                  onClick: () 
                                  {
                                    Navigator.push
                                    (
                                      context,
                                      MaterialPageRoute
                                      (
                                        builder: (context) => DosyaListesiEkrani
                                        (
                                          baslik: 'Videolar',
                                          dosyalar: veriler['Videolar'] ?? [],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}