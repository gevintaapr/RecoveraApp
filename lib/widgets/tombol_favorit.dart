import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorit_controller.dart';
import '../models/favorit_model.dart';
import '../theme/app_theme.dart';
import 'notifikasi_glass.dart';

// Ikon hati untuk menyimpan / menghapus favorit.
// Obx membuat ikon ikut berubah di semua tempat sekaligus
// (kartu katalog, detail, halaman Favorit) saat daftar favorit berubah.
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
        icon: Icon(
          sudahFavorit ? Icons.favorite : Icons.favorite_border,
          color: sudahFavorit ? AppTheme.warnaGalat : AppTheme.warnaTeksRedup,
        ),
        onPressed: () async {
          final bool tersimpan = await favoritController.toggleFavorit(favorit);
          if (!context.mounted) return;
          tampilkanNotifikasiGlass(
            pesan: tersimpan ? 'Disimpan ke Favorit' : 'Dihapus dari Favorit',
            ikon: tersimpan ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            warnaIkon: tersimpan ? AppTheme.warnaGalat : AppTheme.warnaTeksRedup,
          );
        },
      );
    });
  }
}
