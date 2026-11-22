import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Tombol ikon bulat di atas header biru (gaya Recovera lama: putih 18% + garis
// putih 30%), dipakai untuk Favorit dan Notifikasi. jumlahBadge > 0 menampilkan angka.
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
        child: Material(
          color: AppTheme.warnaPutih18,
          shape: const CircleBorder(side: BorderSide(color: AppTheme.warnaPutih30)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: AppTheme.ukuranTombolIkon,
              height: AppTheme.ukuranTombolIkon,
              child: Icon(ikon, size: AppTheme.ikonNav, color: AppTheme.warnaPermukaan, semanticLabel: keterangan),
            ),
          ),
        ),
      ),
    );
  }
}
