import 'package:flutter/material.dart';

class KategoriKarti extends StatelessWidget {
  final String baslik;
  final IconData ikon;
  final Color renk;
  final int dosyaSayisi;
  final VoidCallback onClick;

  const KategoriKarti({
    super.key,
    required this.baslik,
    required this.ikon,
    required this.renk,
    required this.dosyaSayisi,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
          color: renk.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: renk.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, size: 50, color: renk),
            const SizedBox(height: 15),
            Text(
              baslik,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: renk,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$dosyaSayisi Dosya",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}