import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorit_controller.dart';
import '../models/favorit_model.dart';
import '../theme/app_theme.dart';
import 'notifikasi_glass.dart';

// Ikon hati dalam kotak kecil untuk menyimpan / menghapus favorit.
// Obx membuat ikon ikut berubah di semua tempat sekaligus
// (kartu katalog, detail, halaman Favorit) saat daftar favorit berubah.
// Kotak terlihat 32, area ketuk 44.
class TombolFavorit extends StatelessWidget {
  final FavoritModel favorit;

  const TombolFavorit({super.key, required this.favorit});

  @override
  Widget build(BuildContext context) {
    final FavoritController favoritController = Get.find<FavoritController>();

    return Obx(() {
      final bool sudahFavorit = favoritController.apakahFavorit(favorit.idListing);
      return IconButton(
        tooltip: sudahFavorit ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
        constraints: const BoxConstraints(
          minWidth: AppTheme.ukuranTombolIkon,
          minHeight: AppTheme.ukuranTombolIkon,
        ),
        padding: EdgeInsets.zero,
        icon: Container(
          width: AppTheme.ukuranTombolKecil,
          height: AppTheme.ukuranTombolKecil,
          decoration: BoxDecoration(
            color: sudahFavorit ? AppTheme.warnaLatarBahaya : AppTheme.warnaLatarNetral,
            borderRadius: BorderRadius.circular(AppTheme.radiusChip),
          ),
          child: Icon(
            sudahFavorit ? Icons.favorite : Icons.favorite_border,
            size: AppTheme.ikonKecil,
            color: sudahFavorit ? AppTheme.warnaBahaya : AppTheme.warnaTeksSedang,
          ),
        ),
        onPressed: () async {
          final bool tersimpan = await favoritController.toggleFavorit(favorit);
          if (!context.mounted) return;
          tampilkanNotifikasiGlass(
            pesan: tersimpan ? 'Disimpan ke Favorit' : 'Dihapus dari Favorit',
            ikon: tersimpan ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            warnaIkon: tersimpan ? AppTheme.warnaBahaya : AppTheme.warnaTeksRedup,
          );
        },
      );
    });
  }
}
