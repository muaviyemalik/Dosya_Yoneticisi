import 'package:flutter/material.dart';
import 'dart:io';

class GorselOnizlemeEkrani extends StatelessWidget 
{
  final String dosyaYolu;
  final String dosyaAdi;

  const GorselOnizlemeEkrani({
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center
      (
        child: InteractiveViewer
        (
          child: Image.file(File(dosyaYolu)),
        ),
      ),
    );
  }
}