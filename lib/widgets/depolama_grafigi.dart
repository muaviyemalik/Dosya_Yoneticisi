import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DepolamaGrafigi extends StatelessWidget 
{
  final int belgeSayisi;
  final int gorselSayisi;
  final int videoSayisi;

  const DepolamaGrafigi({
    super.key,
    required this.belgeSayisi,
    required this.gorselSayisi,
    required this.videoSayisi,
  });

  @override
  Widget build(BuildContext context) 
  {
    int toplamDosya = belgeSayisi + gorselSayisi + videoSayisi;
    
    if (toplamDosya == 0) 
    {
      return const SizedBox
      (
        height: 200,
        child: Center(child: Text("Taranan dosya bulunamadı.")),
      );
    }

    return Padding
    (
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column
      (
        children: 
        [
          // 1. KISIM: CİHAZ TOPLAM DEPOLAMA DURUMU (Çizgisel İlerleme Çubuğu)
          Container
          (
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration
            (
              color: Colors.blueGrey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blueGrey.withOpacity(0.1)),
            ),
            child: Column
            (
              crossAxisAlignment: CrossAxisAlignment.start,
              children: 
              [
                const Row
                (
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: 
                  [
                    Text
                    (
                      "Cihaz Hafıza Durumu", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text
                    (
                      "72.5 GB / 128 GB", 
                      style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator
                (
                  value: 0.56, // Şimdilik statik oran, ileride disk alanı servisini bağlayacağız
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 2. KISIM: İÇİ TAM DOLU PASTA GRAFİĞİ
          SizedBox
          (
            height: 160,
            child: PieChart
            (
              PieChartData
              (
                centerSpaceRadius: 0, // Ortadaki boşluğu tamamen kapatıp dolgun pasta yapar
                sectionsSpace: 2,    // Dilimler arası ince estetik boşluk
                sections: 
                [
                  PieChartSectionData
                  (
                    color: Colors.blue,
                    value: belgeSayisi.toDouble(),
                    title: belgeSayisi > 0 ? '$belgeSayisi' : '',
                    radius: 80, // Grafik büyüklüğü
                    titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData
                  (
                    color: Colors.orange,
                    value: gorselSayisi.toDouble(),
                    title: gorselSayisi > 0 ? '$gorselSayisi' : '',
                    radius: 80,
                    titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData
                  (
                    color: Colors.red,
                    value: videoSayisi.toDouble(),
                    title: videoSayisi > 0 ? '$videoSayisi' : '',
                    radius: 80,
                    titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 3. KISIM: ALT GÖSTERGELER (LEGEND)
          Row
          (
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: 
            [
              _gostergeEtiketi("Belgeler", Colors.blue),
              _gostergeEtiketi("Görseller", Colors.orange),
              _gostergeEtiketi("Videolar", Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  // Gösterge öğelerini üreten küçük yardımcı fonksiyon
  Widget _gostergeEtiketi(String metin, Color renk)
  {
    return Row
    (
      children: 
      [
        Container
        (
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text
        (
          metin, 
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }
}