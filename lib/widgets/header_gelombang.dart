import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

import '../theme/app_theme.dart';

// Header bergradien dengan gelombang di bawahnya, dipakai Katalog, Dasbor penjual,
// dan Login. Gelombang adalah motif identitas Recovera (tema laut); isi header
// (sapaan, tombol ikon) dikirim lewat [child].
class HeaderGelombang extends StatelessWidget {
  final Widget child;

  const HeaderGelombang({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Ikon status bar putih karena latar header gelap.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.gradienHeader),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.jarakBesar,
                  AppTheme.jarakKecil,
                  AppTheme.jarakBesar,
                  AppTheme.jarakKecil,
                ),
                child: child,
              ),
              // CATATAN: Menggunakan CustomPaint + Path (elemen di luar modul)
              // Fungsi: menggambar dua lapis gelombang di tepi bawah header.
              // Alasan: widget bawaan Modul II hanya bisa membuat sudut lurus/bulat.
              // Cara kerja: _PelukisGelombang menarik kurva bezier dengan Path, lalu
              //         mengisinya dengan warna latar agar header "menyatu" ke isi layar.
              const SizedBox(
                height: AppTheme.tinggiGelombang,
                width: double.infinity,
                child: CustomPaint(painter: _PelukisGelombang()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PelukisGelombang extends CustomPainter {
  const _PelukisGelombang();

  @override
  void paint(Canvas canvas, Size size) {
    final double l = size.width;
    final double t = size.height;

    // Lapis belakang: cyan transparan, sedikit lebih tinggi.
    final Path lapisBelakang = Path()
      ..moveTo(0, t * 0.6)
      ..cubicTo(l * 0.23, 0, l * 0.46, t, l * 0.69, t * 0.47)
      ..cubicTo(l * 0.85, t * 0.2, l * 0.95, t * 0.3, l, t * 0.4)
      ..lineTo(l, t)
      ..lineTo(0, t)
      ..close();
    canvas.drawPath(lapisBelakang, Paint()..color = AppTheme.warnaGelombang);

    // Lapis depan: warna latar layar.
    final Path lapisDepan = Path()
      ..moveTo(0, t * 0.8)
      ..cubicTo(l * 0.26, t * 0.33, l * 0.51, t * 1.1, l * 0.77, t * 0.6)
      ..cubicTo(l * 0.9, t * 0.5, l * 0.97, t * 0.55, l, t * 0.6)
      ..lineTo(l, t)
      ..lineTo(0, t)
      ..close();
    canvas.drawPath(lapisDepan, Paint()..color = AppTheme.warnaLatar);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
