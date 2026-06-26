import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class PdfOnizlemeEkrani extends StatelessWidget 
{
  final String dosyaYolu;
  final String dosyaAdi;

  const PdfOnizlemeEkrani({
    super.key,
    required this.dosyaYolu,
    required this.dosyaAdi,
  });

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text(dosyaAdi, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: PDFView
      (
        filePath: dosyaYolu,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onError: (error) 
        {
          print(error);
        },
      ),
    );
  }
}