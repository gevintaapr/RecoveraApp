import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';

// Notifikasi Glassmorphic yang meluncur turun dari atas (GetX SnackPosition.TOP).
// Memberikan efek melayang (floating frosted glass) di bagian atas layar.
void tampilkanNotifikasiGlass({
  String? judul,
  required String pesan,
  IconData? ikon,
  Color? warnaIkon,
  bool isError = false,
  Duration durasi = const Duration(seconds: 3),
}) {
  Get.closeCurrentSnackbar();

  Get.rawSnackbar(
    titleText: judul != null
        ? Text(
            judul,
            style: TextStyle(
              fontSize: AppTheme.fontNormal,
              fontWeight: FontWeight.bold,
              color: isError ? Colors.white : AppTheme.warnaTeks,
            ),
          )
        : null,
    messageText: Text(
      pesan,
      style: TextStyle(
        fontSize: AppTheme.fontKecil,
        fontWeight: FontWeight.w500,
        color: isError ? Colors.white : AppTheme.warnaTeks,
      ),
    ),
    icon: Icon(
      ikon ?? (isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded),
      color: warnaIkon ?? (isError ? Colors.white : AppTheme.warnaUtama),
      size: 24,
    ),
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.fromLTRB(AppTheme.jarakSedang, 42, AppTheme.jarakSedang, 0),
    borderRadius: AppTheme.radius,
    backgroundColor: isError
        ? AppTheme.warnaGalat.withValues(alpha: 0.90)
        : Colors.white.withValues(alpha: 0.88),
    borderColor: isError
        ? AppTheme.warnaGalat.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.90),
    borderWidth: 1.2,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
    duration: durasi,
    animationDuration: const Duration(milliseconds: 350),
    forwardAnimationCurve: Curves.easeOutCubic,
    reverseAnimationCurve: Curves.easeInCubic,
    shouldIconPulse: false,
    barBlur: 20, // Efek frosted glass asli
  );
}
