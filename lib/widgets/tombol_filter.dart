import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Tombol persegi di samping kolom cari untuk membuka sheet filter.
// Badge berisi jumlah filter yang sedang aktif (0 = badge disembunyikan).
class TombolFilter extends StatelessWidget {
  final int jumlahAktif;
  final VoidCallback onPressed;

  const TombolFilter({super.key, required this.jumlahAktif, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: jumlahAktif > 0,
      label: Text('$jumlahAktif'),
      // Badge Flutter tidak punya garis tepi; putih polos akan hilang di latar terang,
      // jadi dipakai warna aksen yang sama dengan badge lain.
      backgroundColor: AppTheme.warnaAksen,
      textColor: AppTheme.warnaPermukaan,
      child: Material(
        color: AppTheme.warnaUtama,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: onPressed,
          child: SizedBox(
            width: AppTheme.ukuranTombolIkon,
            height: AppTheme.ukuranTombolIkon,
            child: Icon(
              Icons.tune_rounded,
              size: AppTheme.ikonSedang,
              color: AppTheme.warnaPermukaan,
              semanticLabel: jumlahAktif > 0 ? 'Filter, $jumlahAktif aktif' : 'Filter dan urutkan',
            ),
          ),
        ),
      ),
    );
  }
}
