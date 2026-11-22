import 'package:flutter/material.dart';

import '../models/favorit_model.dart';
import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'price_countdown.dart';
import 'status_badge.dart';
import 'tombol_favorit.dart';

// Kartu satu listing di katalog: gambar, nama, penjual, harga sekarang,
// harga normal dicoret, diskon, sisa hari kedaluwarsa, dan jarak (bila ada).
// Dipakai juga di halaman Stok penjual (untukPenjual = true):
// tombol favorit diganti label status + sisa stok.
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
              _GambarProduk(urlGambar: listing.urlGambar),
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
    ];

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
          Text(keterangan.join(' · '), style: AppTheme.gayaTeksRedup),
        const SizedBox(height: AppTheme.jarakKecil),
        Row(
          children: [
            Text(ListingModel.formatRupiah(listing.hargaSekarang), style: AppTheme.gayaHarga),
            const SizedBox(width: AppTheme.jarakKecil),
            Text(ListingModel.formatRupiah(listing.hargaNormal), style: AppTheme.gayaHargaCoret),
          ],
        ),
        const SizedBox(height: AppTheme.jarakKecil),
        Row(
          children: [
            if (listing.diskonPersen > 0)
              Text(
                '-${listing.diskonPersen}%',
                style: const TextStyle(
                  color: AppTheme.warnaAksen,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.fontKecil,
                ),
              ),
            const Spacer(),
            if (listing.sisaHari != null)
              Text(
                'Kedaluwarsa ${listing.sisaHari} hari lagi',
                style: const TextStyle(
                  fontSize: AppTheme.fontKecil,
                  color: AppTheme.warnaTeksRedup,
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

// Gambar dari internet; bila kosong / gagal dimuat tampilkan ikon.
class _GambarProduk extends StatelessWidget {
  final String? urlGambar;

  const _GambarProduk({required this.urlGambar});

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
      child: (urlGambar == null || urlGambar!.isEmpty)
          ? gambarCadangan
          : Image.network(
              urlGambar!,
              width: AppTheme.gambarKartu,
              height: AppTheme.gambarKartu,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => gambarCadangan,
            ),
    );
  }
}
