import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import '../screens/belge_onizleme_ekrani.dart';
import '../screens/gorsel_onizleme_ekrani.dart';

class FileOpenerService 
{
  // Fonksiyona dosyaAdi parametresini de ekledik
  static Future<void> dosyayiAc(BuildContext context, String dosyaYolu, String dosyaAdi) async 
  {
    String uzanti = dosyaAdi.split('.').last.toLowerCase();

    // 1. KATEGORİ: GÖRSELLER (Uygulama İçi - İnternet Gerektirmez)
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(uzanti)) 
    {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GorselOnizlemeEkrani(
            dosyaYolu: dosyaYolu,
            dosyaAdi: dosyaAdi,
          ),
        ),
      );
      return; // İşlem bitti, fonksiyondan çık
    }

    // 2. KATEGORİ: BELGELER (İnternet Varsa Uygulama İçi, Yoksa Harici)
    if (['pdf', 'docx', 'doc', 'xlsx', 'xls', 'pptx', 'txt'].contains(uzanti)) 
    {
      final List<ConnectivityResult> baglanti = await (Connectivity().checkConnectivity());
      bool internetYok = baglanti.contains(ConnectivityResult.none) || baglanti.isEmpty;

      if (internetYok) 
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İnternet yok. Belge harici uygulamayla açılıyor...'),
            backgroundColor: Colors.orange,
          ),
        );
        await OpenFile.open(dosyaYolu);
      } 
      else 
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İnternet var. Belge sunucuya hazırlanıyor...'),
            backgroundColor: Colors.green,
          ),
        );
        
        // TODO: Dosyayı muaviyecakil.com.tr sunucusuna yükleme kodları buraya gelecek.
        // Şimdilik motor tamamlanana kadar yerel olarak açıyoruz:
        await OpenFile.open(dosyaYolu);
      }
      return; // İşlem bitti, fonksiyondan çık
    }

    // 3. KATEGORİ: VİDEOLAR (Harici Uygulama)
    await OpenFile.open(dosyaYolu);
  }
}