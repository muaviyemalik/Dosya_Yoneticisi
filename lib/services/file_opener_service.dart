import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/pdf_onizleme_ekrani.dart';
import '../screens/belge_onizleme_ekrani.dart';
import '../screens/gorsel_onizleme_ekrani.dart';

class FileOpenerService 
{
  static Future<void> dosyayiAc(BuildContext context, String dosyaYolu, String dosyaAdi) async 
  {
    String uzanti = dosyaAdi.split('.').last.toLowerCase();

    // 1. KATEGORİ: GÖRSELLER (Uygulama İçi)
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(uzanti)) 
    {
      Navigator.push
      (
        context,
        MaterialPageRoute
        (
          builder: (context) => GorselOnizlemeEkrani
          (
            dosyaYolu: dosyaYolu,
            dosyaAdi: dosyaAdi,
          ),
        ),
      );
      return; 
    }

    if (uzanti == 'pdf') 
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => PdfOnizlemeEkrani(dosyaYolu: dosyaYolu, dosyaAdi: dosyaAdi)));
      return;
    }

    // 2. KATEGORİ: BELGELER (İnternet Varsa Sunucuya, Yoksa Harici)
    if ([ 'docx', 'doc', 'xlsx', 'xls', 'pptx', 'txt'].contains(uzanti)) 
    {
      final List<ConnectivityResult> baglanti = await (Connectivity().checkConnectivity());
      bool internetYok = baglanti.contains(ConnectivityResult.none) || baglanti.isEmpty;

      if (internetYok) 
      {
        ScaffoldMessenger.of(context).showSnackBar
        (
          const SnackBar
          (
            content: Text('İnternet yok. Belge harici uygulamayla açılıyor...'),
            backgroundColor: Colors.orange,
          ),
        );
        await OpenFile.open(dosyaYolu);
      } 
      else 
      {
        ScaffoldMessenger.of(context).showSnackBar
        (
          const SnackBar
          (
            content: Text('Belge hazırlanıyor, lütfen bekleyin...'),
            backgroundColor: Colors.blue,
          ),
        );
        
        try 
        {
          // Sunucudaki PHP dosyamızın tam adresi
          var uri = Uri.parse('https://muaviyecakil.com.tr/api/upload.php');
          
          // Çok parçalı (Multipart) dosya transferi başlatıyoruz
          var request = http.MultipartRequest('POST', uri);
          request.files.add(await http.MultipartFile.fromPath('dosya', dosyaYolu));

          // İsteği gönder ve cevabı bekle
          var response = await request.send();
          
          if (response.statusCode == 200) 
          {
            // Gelen JSON verisini metne çevirip okuyoruz
            var responseData = await response.stream.bytesToString();
            var jsonData = json.decode(responseData);

            if (jsonData['basari'] == true) 
            {
              // Yükleme başarılıysa sunucudan gelen tam URL'yi al
              String yuklenenUrl = jsonData['url'];
              
              // Orijinal uygulamanın üzerine tarayıcı (WebView) ekranımızı açıyoruz
              if (context.mounted) 
              {
                Navigator.push
                (
                  context,
                  MaterialPageRoute
                  (
                    builder: (context) => BelgeOnizlemeEkrani
                    (
                      dosyaAdi: dosyaAdi,
                      uzaktanUrl: yuklenenUrl,
                    ),
                  ),
                );
              }
            } 
            else 
            {
              // PHP scriptinden 'basari = false' dönerse
              if (context.mounted)
              {
                ScaffoldMessenger.of(context).showSnackBar
                (
                  SnackBar(content: Text('Sunucu hatası: ${jsonData['mesaj']}')),
                );
                await OpenFile.open(dosyaYolu); // Hata durumunda yine yerel aç
              }
            }
          } 
          else 
          {
            if (context.mounted)
            {
              ScaffoldMessenger.of(context).showSnackBar
              (
                const SnackBar(content: Text('Sunucuya bağlanılamadı. Yerel açılıyor...')),
              );
              await OpenFile.open(dosyaYolu);
            }
          }
        } 
        catch (e) 
        {
          if (context.mounted)
          {
            ScaffoldMessenger.of(context).showSnackBar
            (
              const SnackBar(content: Text('Bir hata oluştu. Yerel açılıyor...')),
            );
            await OpenFile.open(dosyaYolu);
          }
        }
      }
      return; 
    }

    // 3. KATEGORİ: VİDEOLAR (Harici)
    await OpenFile.open(dosyaYolu);
  }
}