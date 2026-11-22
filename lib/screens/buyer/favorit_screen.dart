import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/favorit_controller.dart';
import '../../models/favorit_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chip_lembut.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/kartu_favorit.dart';
import '../../widgets/notifikasi_glass.dart';

// Halaman Favorit (pembeli). Dibuka dengan Get.toNamed(AppRoutes.favorit).
// Data: FavoritController.daftarFavorit (isi Hive), ditampilkan dengan Obx + ListView.builder.
// Hapus favorit: geser item ke kiri (Dismissible) atau ketuk ikon hati.
// Tombol lonceng (TombolIngatkan): pengingat 30 menit sebelum lelang berakhir (Modul VII);
// status aktifnya disimpan di Hive dan ikut menyala di halaman detail.
// Hapus favorit -> pengingatnya ikut dibatalkan (FavoritController.hapus).
// Tidak ada setState: controller mengubah daftar, lalu Obx menggambar ulang otomatis.
class FavoritScreen extends StatelessWidget {
  const FavoritScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FavoritController favoritController = Get.find<FavoritController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.warnaPermukaan,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Favorit'),
            Text(
              'Tersimpan di HP ini',
              style: TextStyle(fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w400, color: AppTheme.warnaTeksRedup),
            ),
          ],
        ),
        actions: [
          Obx(() => ChipLembut(
                teks: '${favoritController.jumlahFavorit} produk',
                warnaLatar: AppTheme.warnaLatarBahaya,
                warnaTeks: AppTheme.warnaTeksPeringatan,
              )),
          const SizedBox(width: AppTheme.jarakSedang),
        ],
      ),
      body: Obx(() {
        final List<FavoritModel> daftarFavorit = favoritController.daftarFavorit;
        if (daftarFavorit.isEmpty) {
          return const EmptyState(
            ikon: Icons.favorite_border,
            pesan: 'Belum ada favorit.\nKetuk ikon hati di katalog untuk menyimpan produk.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.jarakSedang),
          // +2: baris info di atas dan petunjuk geser di bawah.
          itemCount: daftarFavorit.length + 2,
          itemBuilder: (context, indeks) {
            if (indeks == 0) return const _InfoHargaTersimpan();
            if (indeks == daftarFavorit.length + 1) return const _PetunjukGeser();
            final FavoritModel favorit = daftarFavorit[indeks - 1];
            // Dismissible: item bisa digeser ke kiri untuk dihapus.
            // key wajib unik agar Flutter tahu item mana yang digeser.
            return Dismissible(
              key: ValueKey<int>(favorit.idListing),
              direction: DismissDirection.endToStart,
              background: const _LatarHapus(),
              onDismissed: (_) => _hapusFavorit(context, favoritController, favorit),
              child: KartuFavorit(favorit: favorit),
            );
          },
        );
      }),
    );
  }

  Future<void> _hapusFavorit(
    BuildContext context,
    FavoritController favoritController,
    FavoritModel favorit,
  ) async {
    await favoritController.hapus(favorit.idListing);
    if (!context.mounted) return;
    tampilkanNotifikasiGlass(
      pesan: '${favorit.namaProduk} dihapus dari Favorit',
      ikon: Icons.delete_outline_rounded,
      warnaIkon: AppTheme.warnaTeksRedup,
    );
  }
}

class _InfoHargaTersimpan extends StatelessWidget {
  const _InfoHargaTersimpan();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.jarakKecil),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang, vertical: AppTheme.jarakKecil),
      decoration: BoxDecoration(
        color: AppTheme.warnaLatarInfo,
        borderRadius: BorderRadius.circular(AppTheme.radiusTombol),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: AppTheme.ikonKecil, color: AppTheme.warnaTeksInfo),
          SizedBox(width: AppTheme.jarakKecil),
          Expanded(
            child: Text(
              'Harga di bawah adalah harga saat disimpan. Buka produk untuk harga terbaru.',
              style: TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksInfo),
            ),
          ),
        ],
      ),
    );
  }
}

class _PetunjukGeser extends StatelessWidget {
  const _PetunjukGeser();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: AppTheme.jarakKecil),
      child: Text(
        'Geser kartu ke kiri untuk menghapus',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup),
      ),
    );
  }
}

// Latar merah berikon tempat sampah yang terlihat saat item digeser.
class _LatarHapus extends StatelessWidget {
  const _LatarHapus();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.only(bottom: AppTheme.jarakKecil),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakBesar),
      decoration: BoxDecoration(
        color: AppTheme.warnaGalat,
        borderRadius: BorderRadius.circular(AppTheme.radiusBesar),
      ),
      child: const Icon(Icons.delete_outline, color: AppTheme.warnaPermukaan, semanticLabel: 'Hapus'),
    );
  }
}
