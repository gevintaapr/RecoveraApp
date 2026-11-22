import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Pembungkus kaca untuk BottomNavigationBar di MainShell.
// BottomNavigationBar-nya tetap ditulis di MainShell (bukti Modul IV); widget ini
// hanya memberi latar putih semi-transparan, blur, dan garis atas.
// Pasangkan dengan Scaffold(extendBody: true) agar isi layar terlihat di belakangnya.
class BarNavigasiKaca extends StatelessWidget {
  final BottomNavigationBar child;

  const BarNavigasiKaca({super.key, required this.child});

  // Ikon tab aktif: dibungkus pil biru muda, sesuai desain.
  static Widget ikonAktif(IconData ikon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakBesar, vertical: AppTheme.jarakMini),
      decoration: BoxDecoration(
        color: AppTheme.warnaLatarInfo,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Icon(ikon, size: AppTheme.ikonSedang),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      // CATATAN: Menggunakan BackdropFilter + ImageFilter.blur (elemen di luar modul)
      // Fungsi: memburamkan isi layar yang tergulir di belakang bar navigasi.
      // Alasan: bar navigasi kaca adalah salah satu dari dua aksen kaca di desain.
      // Cara kerja: ClipRect membatasi area blur hanya setinggi bar, lalu
      //         BackdropFilter mengaburkan konten di belakangnya.
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppTheme.blurKaca, sigmaY: AppTheme.blurKaca),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppTheme.warnaBarKaca,
            border: Border(top: BorderSide(color: AppTheme.warnaGarisTegas)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppTheme.warnaTeksInfo,
                unselectedItemColor: AppTheme.warnaTeksRedup,
                selectedLabelStyle: TextStyle(fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w700),
                unselectedLabelStyle: TextStyle(fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w600),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
