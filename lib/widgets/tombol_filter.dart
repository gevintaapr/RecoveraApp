import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Tombol filter di samping kolom cari (Beranda Recovera lama):
// putih bergaris saat tidak ada filter; biru + angka jumlah filter saat ada.
class TombolFilter extends StatelessWidget {
  final int jumlahAktif;
  final VoidCallback onPressed;

  const TombolFilter({super.key, required this.jumlahAktif, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool aktif = jumlahAktif > 0;
    return Semantics(
      button: true,
      label: aktif ? 'Filter, $jumlahAktif aktif' : 'Filter dan urutkan',
      child: Material(
        color: aktif ? AppTheme.warnaUtama : AppTheme.warnaPermukaan,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusTombol),
          side: BorderSide(color: aktif ? AppTheme.warnaUtama : AppTheme.warnaGarisCari),
        ),
        elevation: aktif ? 2 : 0,
        shadowColor: AppTheme.warnaUtama,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusTombol),
          onTap: onPressed,
          child: Container(
            height: AppTheme.ukuranTombolIkon,
            constraints: const BoxConstraints(minWidth: AppTheme.ukuranTombolIkon),
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: AppTheme.ikonMata, color: aktif ? AppTheme.warnaPermukaan : AppTheme.warnaUtama),
                if (aktif) ...[
                  const SizedBox(width: AppTheme.jarakLabel),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakLabel, vertical: AppTheme.jarakTipis),
                    decoration: BoxDecoration(
                      color: AppTheme.warnaPermukaan,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSedang),
                    ),
                    child: Text(
                      '$jumlahAktif',
                      style: const TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w800, color: AppTheme.warnaUtama),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
