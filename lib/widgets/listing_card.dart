import 'package:flutter/material.dart';

import '../models/favorit_model.dart';
import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'price_countdown.dart';
import 'status_badge.dart';
import 'tombol_favorit.dart';

// Kartu satu listing di katalog (T2):
// - Gambar dengan badge diskon di pojok kiri atas
// - Nama produk & merek
// - Baris info: penjual · jarak · kota gudang
// - Harga sekarang / satuan & harga normal coret
// - Badge sisa hari kedaluwarsa (berwarna merah peringatan bila <= 7 hari)
// - Countdown penurunan harga lelang & tombol favorit
class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;
  final bool untukPenjual;
  final VoidCallback? onHargaTurun; // dipanggil saat hitung mundur harga habis

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.untukPenjual = false,
    this.onHargaTurun,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.warnaPermukaan,
      margin: const EdgeInsets.only(bottom: AppTheme.jarakKecil),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.jarakKecil),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GambarProduk(
                urlGambar: listing.urlGambar,
                diskonPersen: listing.diskonPersen,
              ),
              const SizedBox(width: AppTheme.jarakSedang),
              Expanded(
                child: _InfoListing(
                  listing: listing,
                  untukPenjual: untukPenjual,
                  onHargaTurun: onHargaTurun,
                ),
              ),
              if (untukPenjual)
                StatusBadge(status: listing.status, label: listing.labelStatus)
              else
                TombolFavorit(favorit: FavoritModel.dariListing(listing)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoListing extends StatelessWidget {
  final ListingModel listing;
  final bool untukPenjual;
  final VoidCallback? onHargaTurun;

  const _InfoListing({required this.listing, required this.untukPenjual, this.onHargaTurun});

  @override
  Widget build(BuildContext context) {
    final List<String> keterangan = [
      if (untukPenjual) 'Stok ${listing.stok} ${listing.satuan}',
      if (!untukPenjual && listing.namaPenjual != null) listing.namaPenjual!,
      if (listing.jarakKm != null) ListingModel.formatJarak(listing.jarakKm!),
      if (listing.kotaGudang != null && listing.kotaGudang!.isNotEmpty) listing.kotaGudang!,
    ];

    final bool segeraKedaluwarsa = (listing.sisaHari ?? 999) <= 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          listing.namaProduk,
          style: AppTheme.gayaSubjudul,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (keterangan.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              keterangan.join(' · '),
              style: AppTheme.gayaTeksRedup.copyWith(fontSize: AppTheme.fontKecil),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(height: AppTheme.jarakKecil),
        // Harga / satuan & Coret
        Row(
          children: [
            Text(
              '${ListingModel.formatRupiah(listing.hargaSekarang)} / ${listing.satuan}',
              style: AppTheme.gayaHarga,
            ),
            const SizedBox(width: AppTheme.jarakKecil),
            Text(
              ListingModel.formatRupiah(listing.hargaNormal),
              style: AppTheme.gayaHargaCoret,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.jarakKecil / 2),
        // Sisa Hari Kedaluwarsa
        if (listing.sisaHari != null)
          Row(
            children: [
              Icon(
                segeraKedaluwarsa ? Icons.warning_amber_rounded : Icons.access_time_rounded,
                size: 13,
                color: segeraKedaluwarsa ? AppTheme.warnaGalat : AppTheme.warnaTeksRedup,
              ),
              const SizedBox(width: 4),
              Text(
                'Kedaluwarsa ${listing.sisaHari} hari lagi',
                style: TextStyle(
                  fontSize: AppTheme.fontKecil,
                  fontWeight: segeraKedaluwarsa ? FontWeight.bold : FontWeight.normal,
                  color: segeraKedaluwarsa ? AppTheme.warnaGalat : AppTheme.warnaTeksRedup,
                ),
              ),
            ],
          ),
        // Hitung mundur hidup ke penurunan harga berikutnya (hanya listing aktif).
        if (listing.status == 'active' && listing.waktuTurunBerikutnya != null) ...[
          const SizedBox(height: AppTheme.jarakKecil / 2),
          PriceCountdown(
            waktuTurun: listing.waktuTurunBerikutnya!,
            onHargaTurun: onHargaTurun,
            ringkas: true,
          ),
        ],
      ],
    );
  }
}

// Gambar dari internet dengan badge diskon di pojok kiri atas (T2).
class _GambarProduk extends StatelessWidget {
  final String? urlGambar;
  final int diskonPersen;

  const _GambarProduk({required this.urlGambar, required this.diskonPersen});

  @override
  Widget build(BuildContext context) {
    const Widget gambarCadangan = SizedBox(
      width: AppTheme.gambarKartu,
      height: AppTheme.gambarKartu,
      child: ColoredBox(
        color: AppTheme.warnaGaris,
        child: Icon(Icons.image_outlined, color: AppTheme.warnaTeksRedup),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.jarakKecil),
      child: SizedBox(
        width: AppTheme.gambarKartu,
        height: AppTheme.gambarKartu,
        child: Stack(
          children: [
            Positioned.fill(
              child: (urlGambar == null || urlGambar!.isEmpty)
                  ? gambarCadangan
                  : Image.network(
                      urlGambar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => gambarCadangan,
                    ),
            ),
            if (diskonPersen > 0)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.warnaAksen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-$diskonPersen%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
