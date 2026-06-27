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
  List<File> _sonDosyalar = [];

  @override
  void initState()
  {
    super.initState();
    _izinVeTaramaBaslat();
    _sonDosyalariYukle();
  }

  Future<void> _sonDosyalariYukle() async
  {
    var dosyalar = await RecentFilesService.dosyalariGetir();

    setState(() {
      _sonDosyalar = dosyalar;
    });
  }

  Future<void> _izinVeTaramaBaslat() async
  {
    bool izinVerildiMi = await PermissionService.depolamaIzniniIste();

    if (izinVerildiMi)
    {
      setState(() {
        _dosyaTaramasi = FileService.dosyalariTara();
      });
    }
    else
    {
      setState(() {
        _izinReddedildi = true;
      });
    }
  }

  @override
  Widget build(BuildContext context)
  {
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
              child: Text(
                'Uygulamayı kullanabilmek için depolama izni vermelisiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            )
          : _dosyaTaramasi == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<Map<String, List<File>>>(
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
                      return const Center(
                        child: Text("Dosyalar okunurken bir hata oluştu."),
                      );
                    }

                    final veriler = snapshot.data!;

                    int belgeAdedi = veriler['Belgeler']?.length ?? 0;
                    int gorselAdedi = veriler['Gorseller']?.length ?? 0;
                    int videoAdedi = veriler['Videolar']?.length ?? 0;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          if (_sonDosyalar.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Text(
                                    "Son Kullanılanlar",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _sonDosyalar.length,
                                    itemBuilder: (context, i)
                                    {
                                      String dosyaAdi =
                                          _sonDosyalar[i]
                                              .path
                                              .split('/')
                                              .last;

                                      return Container(
                                        width: 80,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: InkWell(
                                          onTap: () =>
                                              FileOpenerService.dosyayiAc(
                                                context,
                                                _sonDosyalar[i].path,
                                                dosyaAdi,
                                              ),
                                          child: Column(
                                            children: [
                                              const Icon(
                                                Icons.description,
                                                size: 40,
                                                color: Colors.blueGrey,
                                              ),
                                              Text(
                                                dosyaAdi,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),

                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 4.0,
                              bottom: 12.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: const LinearProgressIndicator(
                                value: 0.56,
                                minHeight: 6,
                                backgroundColor: Colors.black12,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueGrey,
                                ),
                              ),
                            ),
                          ),

                          DepolamaGrafigi(
                            belgeSayisi: belgeAdedi,
                            gorselSayisi: gorselAdedi,
                            videoSayisi: videoAdedi,
                          ),

                          GridView.count(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            padding: const EdgeInsets.all(16),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              KategoriKarti(
                                baslik: 'Belgeler',
                                ikon: Icons.description,
                                renk: Colors.blue,
                                dosyaSayisi: belgeAdedi,
                                onClick: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DosyaListesiEkrani(
                                          baslik: 'Belgeler',
                                          dosyalar:
                                              veriler['Belgeler'] ??
                                              [],
                                          mevcutDizin:
                                              '/storage/emulated/0/Documents',
                                        ),
                                  ),
                                ),
                              ),
                              KategoriKarti(
                                baslik: 'Görseller',
                                ikon: Icons.image,
                                renk: Colors.orange,
                                dosyaSayisi: gorselAdedi,
                                onClick: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DosyaListesiEkrani(
                                          baslik: 'Görseller',
                                          dosyalar:
                                              veriler['Gorseller'] ??
                                              [],
                                          mevcutDizin:
                                              '/storage/emulated/0/Pictures',
                                        ),
                                  ),
                                ),
                              ),
                              KategoriKarti(
                                baslik: 'Videolar',
                                ikon: Icons.play_circle_fill,
                                renk: Colors.red,
                                dosyaSayisi: videoAdedi,
                                onClick: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DosyaListesiEkrani(
                                          baslik: 'Videolar',
                                          dosyalar:
                                              veriler['Videolar'] ??
                                              [],
                                          mevcutDizin:
                                              '/storage/emulated/0/Movies',
                                        ),
                                  ),
                                ),
                              ),
                              KategoriKarti(
                                baslik: 'Tüm Dosyalar',
                                ikon: Icons.folder_open,
                                renk: Colors.purple,
                                dosyaSayisi: -1,
                                onClick: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        KlasorTarayiciEkrani(
                                          dizin: Directory(
                                            '/storage/emulated/0/',
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}