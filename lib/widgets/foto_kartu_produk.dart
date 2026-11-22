import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Foto 88x88 di kartu produk (_ListingImage Recovera lama): pita diskon merah di
// kiri atas, badge kecil beku/dingin di kanan atas, ikon cadangan bila tanpa foto.
class FotoKartuProduk extends StatelessWidget {
  final String? urlGambar;
  final int diskonPersen;
  final String? jenisPenyimpanan; // ambient / chilled / frozen

  const FotoKartuProduk({super.key, required this.urlGambar, required this.diskonPersen, this.jenisPenyimpanan});

  @override
  Widget build(BuildContext context) {
    const Widget cadangan = ColoredBox(
      color: AppTheme.warnaLatarNetral,
      child: Center(child: Icon(Icons.inventory_2_outlined, size: AppTheme.ikonNav, color: AppTheme.warnaTeksRedup)),
    );
    final bool beku = jenisPenyimpanan == 'frozen';
    final bool dingin = jenisPenyimpanan == 'chilled';

    return SizedBox(
      width: AppTheme.gambarKartu,
      height: AppTheme.gambarKartu,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusTombol),
              child: (urlGambar == null || urlGambar!.isEmpty)
                  ? cadangan
                  : Image.network(urlGambar!, fit: BoxFit.cover, errorBuilder: (context, error, stack) => cadangan),
            ),
          ),
          if (diskonPersen > 0)
            Positioned(
              top: AppTheme.jarakMini,
              left: 0,
              // CATATAN: Menggunakan ClipPath + CustomClipper (elemen di luar modul)
              // Fungsi: memotong ujung kanan label diskon menjadi bentuk ekor pita.
              // Alasan: ciri pita diskon di kartu produk Recovera.
              // Cara kerja: Path persegi yang sisi kanannya ditarik masuk 5 px di tengah.
              child: ClipPath(
                clipper: _PemotongPita(),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(AppTheme.jarakLabel, AppTheme.jarakTipis, AppTheme.radiusSedang, AppTheme.jarakTipis),
                  color: AppTheme.warnaPitaDiskon,
                  child: Text(
                    '-$diskonPersen%',
                    style: const TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w600, color: AppTheme.warnaPermukaan),
                  ),
                ),
              ),
            ),
          if (beku || dingin)
            Positioned(
              top: AppTheme.jarakMini,
              right: AppTheme.jarakMini,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakMini, vertical: AppTheme.jarakTipis),
                decoration: BoxDecoration(
                  color: beku ? AppTheme.warnaBekuBadge : AppTheme.warnaDinginBadge,
                  borderRadius: BorderRadius.circular(AppTheme.jarakMini),
                ),
                child: Icon(
                  beku ? Icons.ac_unit_rounded : Icons.thermostat_rounded,
                  size: AppTheme.fontLabel,
                  color: AppTheme.warnaPermukaan,
                  semanticLabel: beku ? 'Beku' : 'Dingin',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PemotongPita extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width - 5, size.height / 2)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
