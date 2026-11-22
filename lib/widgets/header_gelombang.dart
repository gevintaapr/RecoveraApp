import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

import '../theme/app_theme.dart';

// Header biru bergelombang ala Recovera (RecoveraWaveHeader lama), dipakai di
// Katalog, Dasbor penjual, dan Login. Isi header dikirim lewat [child];
// tingginya mengikuti isi + ruang gelombang di bawah.
class HeaderGelombang extends StatelessWidget {
  final Widget child;

  const HeaderGelombang({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Ikon status bar putih karena latar header biru.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      // CATATAN: Menggunakan ClipPath + CustomClipper (elemen di luar modul)
      // Fungsi: memotong tepi bawah header menjadi bentuk gelombang.
      // Alasan: ciri khas tampilan Recovera; widget Modul II hanya bersudut lurus/bulat.
      // Cara kerja: dua lapis Container dipotong dengan Path kurva bezier; lapis
      //         belakang (biru muda) sedikit lebih rendah sehingga tampak dua gelombang.
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipPath(
              clipper: _PemotongGelombangBelakang(),
              child: const ColoredBox(color: AppTheme.warnaGelombang),
            ),
          ),
          ClipPath(
            clipper: _PemotongGelombangDepan(),
            child: Container(
              width: double.infinity,
              color: AppTheme.warnaUtama,
              padding: const EdgeInsets.only(bottom: AppTheme.tinggiGelombang),
              child: SafeArea(
                bottom: false,
                // Jarak rapat seperti header Recovera lama (16, 12, 16, lalu ruang gelombang).
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.jarakTepi,
                    AppTheme.jarakMini,
                    AppTheme.jarakTepi,
                    0,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PemotongGelombangDepan extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 18)
      ..cubicTo(size.width * 0.3, size.height + 4, size.width * 0.68, size.height - 34, size.width,
          size.height - 14)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _PemotongGelombangBelakang extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 8)
      ..cubicTo(size.width * 0.34, size.height + 10, size.width * 0.7, size.height - 26, size.width,
          size.height - 5)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
