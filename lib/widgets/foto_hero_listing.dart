import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';

// Foto besar di atas halaman detail: label hemat di kiri atas, tanggal kedaluwarsa
// di kanan atas, dan nama produk + penjual di bawah, di atas lapisan navy gelap
// supaya teks putih tetap terbaca di foto apa pun.
class FotoHeroListing extends StatelessWidget {
  final ListingModel listing;
  final String? teksJarak;

  const FotoHeroListing({super.key, required this.listing, this.teksJarak});

  @override
  Widget build(BuildContext context) {
    final List<String> keterangan = [
      if (listing.merek != null && listing.merek!.isNotEmpty) listing.merek!,
      if (listing.namaPenjual != null) listing.namaPenjual!,
      ?teksJarak,
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusBesar),
      child: SizedBox(
        height: AppTheme.gambarDetail,
        child: Stack(
          fit: StackFit.expand,
          children: [
            (listing.urlGambar == null || listing.urlGambar!.isEmpty)
                ? const _FotoKosong()
                : Image.network(
                    listing.urlGambar!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const _FotoKosong(),
                  ),
            if (listing.diskonPersen > 0)
              Positioned(
                top: AppTheme.jarakSedang,
                left: AppTheme.jarakSedang,
                child: _Label(
                  teks: 'Hemat ${listing.diskonPersen}%',
                  latar: AppTheme.warnaAksen,
                  warnaTeks: AppTheme.warnaPermukaan,
                ),
              ),
            Positioned(
              top: AppTheme.jarakSedang,
              right: AppTheme.jarakSedang,
              child: _Label(
                teks: 'Kedaluwarsa ${ListingModel.formatTanggal(listing.tanggalKedaluwarsa)}',
                latar: AppTheme.warnaPermukaan,
                warnaTeks: AppTheme.warnaSukses,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.jarakSedang,
                  AppTheme.jarakBesar * 2,
                  AppTheme.jarakSedang,
                  AppTheme.jarakSedang,
                ),
                decoration: const BoxDecoration(gradient: AppTheme.gradienScrim),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.namaProduk,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppTheme.fontBesar,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.warnaPermukaan,
                      ),
                    ),
                    if (keterangan.isNotEmpty)
                      Text(
                        keterangan.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaPermukaan),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String teks;
  final Color latar;
  final Color warnaTeks;

  const _Label({required this.teks, required this.latar, required this.warnaTeks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakKecil, vertical: AppTheme.jarakMini / 2),
      decoration: BoxDecoration(color: latar, borderRadius: BorderRadius.circular(AppTheme.radiusKapsul)),
      child: Text(
        teks,
        style: TextStyle(fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w800, color: warnaTeks),
      ),
    );
  }
}

class _FotoKosong extends StatelessWidget {
  const _FotoKosong();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppTheme.warnaLatarNetral,
      child: Center(
        child: Icon(Icons.inventory_2_outlined, size: AppTheme.ikonLogo, color: AppTheme.warnaTeksRedup),
      ),
    );
  }
}
