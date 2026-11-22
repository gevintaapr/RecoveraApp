import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/favorit_controller.dart';
import '../../models/favorit_model.dart';
import '../../models/listing_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/notifikasi_glass.dart';
import '../../widgets/tombol_favorit.dart';
import '../../widgets/tombol_ingatkan.dart';
import 'listing_detail_screen.dart';

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
      appBar: AppBar(title: const Text('Favorit')),
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
          itemCount: daftarFavorit.length,
          itemBuilder: (context, indeks) {
            final FavoritModel favorit = daftarFavorit[indeks];
            // Dismissible: item bisa digeser ke kiri untuk dihapus.
            // key wajib unik agar Flutter tahu item mana yang digeser.
            return Dismissible(
              key: ValueKey<int>(favorit.idListing),
              direction: DismissDirection.endToStart,
              background: const _LatarHapus(),
              onDismissed: (_) => _hapusFavorit(context, favoritController, favorit),
              child: _KartuFavorit(favorit: favorit),
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

// Latar merah berikon tempat sampah yang terlihat saat item digeser.
class _LatarHapus extends StatelessWidget {
  const _LatarHapus();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.jarakKecil / 2),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakBesar),
      decoration: BoxDecoration(
        color: AppTheme.warnaGalat,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: const Icon(Icons.delete_outline, color: AppTheme.warnaPermukaan),
    );
  }
}

class _KartuFavorit extends StatelessWidget {
  final FavoritModel favorit;

  const _KartuFavorit({required this.favorit});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.warnaPermukaan,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.jarakKecil / 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: InkWell(
        // Detail memuat harga terbaru dari server (Navigator.push + idListing, Modul IV).
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailScreen(idListing: favorit.idListing),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.jarakKecil),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radius),
                child: _gambar(),
              ),
              const SizedBox(width: AppTheme.jarakSedang),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favorit.namaProduk,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppTheme.jarakKecil / 2),
                    Text(
                      ListingModel.formatRupiah(favorit.hargaSaatDisimpan),
                      style: AppTheme.gayaHarga,
                    ),
                    Text(
                      favorit.lelangSudahBerakhir ? 'Lelang berakhir' : 'Harga saat disimpan',
                      style: TextStyle(
                        fontSize: AppTheme.fontKecil,
                        color: favorit.lelangSudahBerakhir
                            ? AppTheme.warnaGalat
                            : AppTheme.warnaTeksRedup,
                      ),
                    ),
                  ],
                ),
              ),
              // Lonceng: pasang/batalkan pengingat 30 menit sebelum lelang berakhir (Modul VII).
              // Statusnya tersimpan di Hive, sama dengan tombol "Ingatkan saya" di detail.
              if (!favorit.lelangSudahBerakhir) TombolIngatkan(favorit: favorit, bentukIkon: true),
              TombolFavorit(favorit: favorit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gambar() {
    const Widget gambarCadangan = SizedBox(
      width: AppTheme.gambarKartu,
      height: AppTheme.gambarKartu,
      child: ColoredBox(
        color: AppTheme.warnaGaris,
        child: Icon(Icons.image_outlined, color: AppTheme.warnaTeksRedup),
      ),
    );
    if (favorit.urlGambar == null || favorit.urlGambar!.isEmpty) return gambarCadangan;
    return Image.network(
      favorit.urlGambar!,
      width: AppTheme.gambarKartu,
      height: AppTheme.gambarKartu,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => gambarCadangan,
    );
  }
}
