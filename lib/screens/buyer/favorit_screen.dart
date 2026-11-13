import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/favorit_controller.dart';
import '../../models/favorit_model.dart';
import '../../models/listing_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tombol_favorit.dart';
import 'listing_detail_screen.dart';

// Halaman Favorit (pembeli). Dibuka dengan Get.toNamed(AppRoutes.favorit).
// Data: FavoritController.daftarFavorit (isi Hive), ditampilkan dengan Obx + GridView.
// Tidak ada setState: saat hati diketuk, controller mengubah daftar,
// lalu Obx menggambar ulang grid secara otomatis.
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
        return GridView.builder(
          padding: const EdgeInsets.all(AppTheme.jarakSedang),
          itemCount: daftarFavorit.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppTheme.jarakKecil,
            crossAxisSpacing: AppTheme.jarakKecil,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, indeks) => _KartuFavorit(favorit: daftarFavorit[indeks]),
        );
      }),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: InkWell(
        // Detail memuat harga terbaru dari server (Navigator.push + idListing, Modul IV).
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailScreen(idListing: favorit.idListing),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _gambar(),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: ColoredBox(
                      color: AppTheme.warnaPermukaan,
                      child: TombolFavorit(favorit: favorit),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.jarakKecil),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favorit.namaProduk,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _gambar() {
    const Widget gambarCadangan = ColoredBox(
      color: AppTheme.warnaGaris,
      child: Icon(Icons.image_outlined, color: AppTheme.warnaTeksRedup),
    );
    if (favorit.urlGambar == null || favorit.urlGambar!.isEmpty) return gambarCadangan;
    return Image.network(
      favorit.urlGambar!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => gambarCadangan,
    );
  }
}
