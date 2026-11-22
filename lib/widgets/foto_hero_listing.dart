import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';

// Kartu hero di atas Detail produk (_buildHeroCard Recovera lama):
// foto 16:10 + lapisan gelap, chip "Hemat X%" & sisa hari, lalu BATCH, nama
// produk, dan gudang di atas foto; pita bawah berisi penyimpanan & kedaluwarsa.
class FotoHeroListing extends StatelessWidget {
  final ListingModel listing;
  final String? teksJarak;

  const FotoHeroListing({super.key, required this.listing, this.teksJarak});

  String get _teksPenyimpanan {
    switch (listing.jenisPenyimpanan) {
      case 'frozen':
        return 'Frozen (beku)';
      case 'chilled':
        return 'Chilled (dingin)';
      case 'ambient':
        return 'Ambient (suhu ruang)';
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String gudang = [
      'Gudang ${listing.namaPenjual ?? '-'}',
      if (listing.kotaGudang != null) listing.kotaGudang!,
    ].join(' • ');

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.warnaPermukaan,
        borderRadius: BorderRadius.circular(AppTheme.jarakInput),
        boxShadow: const [BoxShadow(color: AppTheme.warnaBayanganKartu, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                (listing.urlGambar == null || listing.urlGambar!.isEmpty)
                    ? const _FotoKosong()
                    : Image.network(listing.urlGambar!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const _FotoKosong()),
                // Gelap di atas & bawah agar chip dan teks putih terbaca di foto apa pun.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppTheme.warnaScrimAtas, Colors.transparent, AppTheme.warnaScrimBawah],
                      stops: [0, 0.45, 1],
                    ),
                  ),
                ),
                if (listing.diskonPersen > 0)
                  Positioned(
                    top: AppTheme.radiusSedang,
                    left: AppTheme.radiusSedang,
                    child: _Chip(teks: 'Hemat ${listing.diskonPersen}%', latar: AppTheme.warnaChipHemat, warnaTeks: AppTheme.warnaPermukaan),
                  ),
                if (listing.sisaHari != null)
                  Positioned(
                    top: AppTheme.radiusSedang,
                    right: AppTheme.radiusSedang,
                    child: _Chip(
                      teks: 'Sisa ${listing.sisaHari} Hari',
                      latar: AppTheme.warnaPanelPeta,
                      warnaTeks: listing.sisaHari! <= 7 ? AppTheme.warnaSisaSedang : AppTheme.warnaSisaAman,
                    ),
                  ),
                Positioned(
                  left: AppTheme.jarakSedang,
                  right: AppTheme.jarakSedang,
                  bottom: AppTheme.radiusSedang,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (listing.nomorBatch != null)
                        Text(
                          'BATCH #${listing.nomorBatch}',
                          style: const TextStyle(
                            fontSize: AppTheme.fontLabel,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.warnaBatchHero,
                            letterSpacing: 0.5,
                          ),
                        ),
                      Text(
                        listing.namaProduk,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: AppTheme.fontSubjudul, fontWeight: FontWeight.w700, color: AppTheme.warnaPermukaan, height: 1.2),
                      ),
                      const SizedBox(height: AppTheme.jarakTipis),
                      Text(
                        teksJarak == null ? gudang : '$gudang ($teksJarak)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaGaris),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Pita info di bawah foto (data asli: penyimpanan & tanggal kedaluwarsa).
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang, vertical: AppTheme.jarakKecil),
            color: AppTheme.warnaLatar,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _teksPenyimpanan,
                    style: const TextStyle(fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w600, color: AppTheme.warnaJudulKartu),
                  ),
                ),
                Text(
                  'Kedaluwarsa ${ListingModel.formatTanggal(listing.tanggalKedaluwarsa)}',
                  style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String teks;
  final Color latar;
  final Color warnaTeks;

  const _Chip({required this.teks, required this.latar, required this.warnaTeks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakKecil, vertical: AppTheme.jarakTipis),
      decoration: BoxDecoration(color: latar, borderRadius: BorderRadius.circular(AppTheme.radiusTombol)),
      child: Text(teks, style: TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w700, color: warnaTeks)),
    );
  }
}

class _FotoKosong extends StatelessWidget {
  const _FotoKosong();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppTheme.warnaGaris,
      child: Center(child: Icon(Icons.inventory_2_rounded, size: AppTheme.ikonLogo, color: AppTheme.warnaTeksRedup)),
    );
  }
}
