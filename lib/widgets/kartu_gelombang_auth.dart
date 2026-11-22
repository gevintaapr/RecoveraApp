import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Kartu putih bertepi atas bergelombang di bawah header biru Login/Register
// (_WaveCardClipper Recovera lama). Latar biru di belakangnya membuat
// lengkungan terlihat seperti sambungan header -> kartu.
class KartuGelombangAuth extends StatelessWidget {
  final Widget child;

  const KartuGelombangAuth({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.warnaUtamaTerang,
      child: LayoutBuilder(
        builder: (context, batas) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: batas.maxHeight),
            // CATATAN: Menggunakan ClipPath + CustomClipper (elemen di luar modul)
            // Fungsi: memotong tepi atas kartu putih menjadi gelombang.
            // Alasan: ciri tampilan Login/Register Recovera.
            // Cara kerja: Path dua kurva bezier dari kiri ke kanan; area di luar
            //         path dibuang sehingga latar biru terlihat di atas kurva.
            child: ClipPath(
              clipper: _PemotongKartu(),
              child: Container(
                width: double.infinity,
                color: AppTheme.warnaPermukaan,
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.jarakAuthSisi,
                  AppTheme.jarakAuthAtas,
                  AppTheme.jarakAuthSisi,
                  AppTheme.jarakAuthAtas - AppTheme.jarakBesar,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PemotongKartu extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double l = size.width;
    return Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 48)
      ..cubicTo(0, 12, l * 0.30, 0, l * 0.50, 22)
      ..cubicTo(l * 0.70, 44, l * 0.90, 4, l, 24)
      ..lineTo(l, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
