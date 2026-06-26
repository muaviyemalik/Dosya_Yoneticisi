import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BelgeOnizlemeEkrani extends StatefulWidget 
{
  final String dosyaAdi;
  final String uzaktanUrl;

  const BelgeOnizlemeEkrani({
    super.key,
    required this.dosyaAdi,
    required this.uzaktanUrl,
  });

  @override
  State<BelgeOnizlemeEkrani> createState() => _BelgeOnizlemeEkraniState();
}

class _BelgeOnizlemeEkraniState extends State<BelgeOnizlemeEkrani> 
{
  late final WebViewController _controller;
  bool _yukleniyor = true;

  @override
  void initState() 
  {
    super.initState();

    // Google Docs Viewer ile dosya linkimizi birleştiriyoruz
    final String url = "https://docs.google.com/gview?embedded=true&url=${widget.uzaktanUrl}";

    // Webview sürücüsünü hazırlıyoruz
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) 
          {
            setState(() 
            {
              _yukleniyor = false; // Sayfa yüklenmesi bittiğinde çemberi gizle
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text(widget.dosyaAdi, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Stack
      (
        children: 
        [
          // Gerçek dökümanı gösterecek olan tarayıcı katmanı
          WebViewWidget(controller: _controller),
          
          // Döküman yüklenirken arkada dönen şık yükleme çemberi
          if (_yukleniyor)
            const Center
            (
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}