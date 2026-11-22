import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Bar aksi yang menempel di bawah layar (detail: jumlah + Beli; form penjual:
// dua tombol). Latar kaca supaya isi yang tergulir masih terlihat samar.
// Dipakai sebagai Scaffold.bottomNavigationBar di layar tanpa bottom nav.
class BarBawahKaca extends StatelessWidget {
  final Widget child;

  const BarBawahKaca({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      // CATATAN: Menggunakan BackdropFilter + ImageFilter.blur (elemen di luar modul)
      // Fungsi: memburamkan isi layar di belakang bar aksi bawah.
      // Alasan: aksen kaca kedua di desain; layar ini tidak punya bottom nav.
      // Cara kerja: sama seperti bar navigasi, blur dibatasi ClipRect.
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppTheme.blurKaca, sigmaY: AppTheme.blurKaca),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppTheme.warnaBarKaca,
            border: Border(top: BorderSide(color: AppTheme.warnaGaris)),
          ),
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: AppTheme.jarakSedang),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.jarakSedang,
                AppTheme.jarakSedang,
                AppTheme.jarakSedang,
                0,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
