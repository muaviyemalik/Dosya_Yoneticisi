import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';

class FileOpenerService 
{
  // context parametresi ekranda bilgi mesajı (SnackBar) göstermek için gerekli
  static Future<void> dosyayiAc(BuildContext context, String dosyaYolu) async 
  {
    // İnternet durumunu kontrol ediyoruz
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    
    // Güncel connectivity_plus paketinde liste döner, bağlantı yok mu diye kontrol ediyoruz
    bool internetYok = connectivityResult.contains(ConnectivityResult.none) || connectivityResult.isEmpty;

    if (internetYok) 
    {
      // --- İNTERNET YOK (ÇEVRİMDIŞI MOD) ---
      ScaffoldMessenger.of(context).showSnackBar
      (
        const SnackBar
        (
          content: Text('İnternet bağlantısı yok. Yerel uygulamayla açılıyor...'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Dosyayı cihazdaki varsayılan uygulamayla (Word, PDF Okuyucu vb.) aç
      await OpenFile.open(dosyaYolu);
      
    } 
    else 
    {
      // --- İNTERNET VAR (ÇEVRİMİÇİ MOD) ---
      ScaffoldMessenger.of(context).showSnackBar
      (
        const SnackBar
        (
          content: Text('İnternet var! Dosya sunucu üzerinden açılacak...'),
          backgroundColor: Colors.green,
        ),
      );
      
      // TODO: İleride muaviyecakil.com.tr üzerindeki nano hosting alanına dosyayı yükleyip,
      // dönen linki Google Docs Viewer ile WebView içinde açacağımız kodlar buraya gelecek.
      
      // Çevrimiçi motoru bir sonraki adımda yazana kadar şimdilik dosyayı yerel olarak açalım:
      await OpenFile.open(dosyaYolu);
    }
  }
}