import 'package:flutter/material.dart';
import 'dart:io';
import 'screens/dosya_listesi_ekrani.dart';
import 'widgets/kategori_karti.dart';
import 'services/file_service.dart';
import 'services/permission_service.dart';

void main() {
  runApp(const DosyaYoneticisiApp());
}

class DosyaYoneticisiApp extends StatelessWidget {
  const DosyaYoneticisiApp({super.key});

  @override
  Widget build(BuildContext context) {
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

// Artık sayfamız dinamik (Stateful) olacak çünkü veriler ve durumlar sürekli değişecek
class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  // Arka planda çalışacak tarama işlemini tutan değişken
  Future<Map<String, List<File>>>? _dosyaTaramasi;
  bool _izinReddedildi = false;

  @override
  void initState() {
    super.initState();
    _izinVeTaramaBaslat(); // Uygulama açılır açılmaz bu fonksiyon tetiklenecek
  }

  Future<void> _izinVeTaramaBaslat() async {
    bool izinVerildiMi = await PermissionService.depolamaIzniniIste();
    
    if (izinVerildiMi) {
      setState(() {
        // İzin verildiyse tarama motorunu çalıştır ve Future'a bağla
        _dosyaTaramasi = FileService.dosyalariTara();
      });
    } else {
      setState(() {
        _izinReddedildi = true; // İzin verilmezse ekranda uyarı göstereceğiz
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              ? const Center(child: CircularProgressIndicator()) // İzin kontrolü yapılırken dönen çember
              : FutureBuilder<Map<String, List<File>>>(
                  future: _dosyaTaramasi,
                  builder: (context, snapshot) {
                    // Veriler henüz gelmediyse yükleme animasyonu göster
                    if (snapshot.connectionState == ConnectionState.waiting) {
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

                    // Herhangi bir hata olursa göster
                    if (snapshot.hasError) {
                      return const Center(child: Text("Dosyalar okunurken bir hata oluştu."));
                    }

                    // Veriler başarıyla geldiyse kartları oluştur
                    final veriler = snapshot.data!;
                    
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          KategoriKarti(
                            baslik: 'Belgeler',
                            ikon: Icons.description,
                            renk: Colors.blue,
                            dosyaSayisi: veriler['Belgeler']?.length ?? 0, // Gerçek belge sayısı
                            onClick: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DosyaListesiEkrani(
                                  baslik: 'Belgeler',
                                  dosyalar: veriler['Belgeler'] ?? [],
                                ),
                              ),
                            );
                          },
                          ),
                          KategoriKarti(
                            baslik: 'Görseller',
                            ikon: Icons.image,
                            renk: Colors.orange,
                            dosyaSayisi: veriler['Gorseller']?.length ?? 0, // Gerçek görsel sayısı
                            onClick: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DosyaListesiEkrani(
                                    baslik: 'Görseller',
                                    dosyalar: veriler['Gorseller'] ?? [],
                                  ),
                                ),
                              );
                            },
                          ),
                          KategoriKarti(
                            baslik: 'Videolar',
                            ikon: Icons.play_circle_fill,
                            renk: Colors.red,
                            dosyaSayisi: veriler['Videolar']?.length ?? 0, // Gerçek video sayısı
                            onClick: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DosyaListesiEkrani(
                                    baslik: 'Videolar',
                                    dosyalar: veriler['Videolar'] ?? [],
                                 ),
                                ),
                             );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}