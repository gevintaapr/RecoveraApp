import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Tombol ikon bulat berefek kaca untuk di atas header bergradien (favorit, lonceng).
// jumlahBadge > 0 menampilkan angka di pojok kanan atas.
class TombolIkonKaca extends StatelessWidget {
  final IconData ikon;
  final String keterangan; // dibacakan pembaca layar, juga tooltip
  final VoidCallback onPressed;
  final int jumlahBadge;

  const TombolIkonKaca({
    super.key,
    required this.ikon,
    required this.keterangan,
    required this.onPressed,
    this.jumlahBadge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: keterangan,
      child: Badge(
        isLabelVisible: jumlahBadge > 0,
        label: Text('$jumlahBadge'),
        backgroundColor: AppTheme.warnaAksen,
        textColor: AppTheme.warnaPermukaan,
        child: ClipOval(
          // CATATAN: Menggunakan BackdropFilter + ImageFilter.blur (elemen di luar modul)
          // Fungsi: memburamkan gradien di belakang tombol (efek kaca).
          // Alasan: desain Ocean Glass memakai kaca sebagai aksen di header.
          // Cara kerja: BackdropFilter mengaburkan apa pun di belakangnya, lalu
          //         lapisan putih 16% + garis putih 35% digambar di atasnya.
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: AppTheme.blurKaca, sigmaY: AppTheme.blurKaca),
            child: Material(
              color: AppTheme.warnaKaca,
              shape: const CircleBorder(side: BorderSide(color: AppTheme.warnaGarisKaca)),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: SizedBox(
                  width: AppTheme.ukuranTombolIkon,
                  height: AppTheme.ukuranTombolIkon,
                  child: Icon(
                    ikon,
                    size: AppTheme.ikonSedang,
                    color: AppTheme.warnaPermukaan,
                    semanticLabel: keterangan,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
