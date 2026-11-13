import 'package:flutter/material.dart';

import '../models/favorit_model.dart';
import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'tombol_favorit.dart';

// Kartu satu listing di katalog: gambar, nama, penjual, harga sekarang,
// harga normal dicoret, diskon, sisa hari kedaluwarsa, dan jarak (bila ada).
class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const ListingCard({super.key, required this.listing, required this.onTap});

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
              Expanded(child: _InfoListing(listing: listing)),
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

  const _InfoListing({required this.listing});

  @override
  Widget build(BuildContext context) {
    final List<String> keterangan = [
      if (listing.namaPenjual != null) listing.namaPenjual!,
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
