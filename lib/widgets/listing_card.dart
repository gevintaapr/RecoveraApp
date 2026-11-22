import 'package:flutter/material.dart';

import '../models/favorit_model.dart';
import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'chip_lembut.dart';
import 'price_countdown.dart';
import 'status_badge.dart';
import 'tombol_favorit.dart';

// Kartu satu listing versi daftar (Katalog pembeli & Stok penjual):
// - kiri: foto 84x84 + pita diskon
// - kanan atas: nama penjual (kapital kecil) dan "Sisa X hari"
// - nama produk, chip hitung mundur "turun ..", jarak & kota gudang
// - bawah: harga / satuan + harga normal coret, lalu tombol hati (pembeli)
//   atau badge status (penjual)
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.jarakKecil),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusBesar),
          side: const BorderSide(color: AppTheme.warnaGaris),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusBesar),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.jarakSedang),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FotoProduk(urlGambar: listing.urlGambar, diskonPersen: listing.diskonPersen),
                const SizedBox(width: AppTheme.jarakSedang),
                Expanded(
                  child: _InfoListing(
                    listing: listing,
                    untukPenjual: untukPenjual,
                    onHargaTurun: onHargaTurun,
                  ),
                ),
              ],
            ),
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
    final String labelAtas = untukPenjual
        ? 'Stok ${listing.stok} ${listing.satuan}'
        : (listing.namaPenjual ?? '');
    final int? sisaHari = listing.sisaHari;
    final List<String> lokasi = [
      if (listing.jarakKm != null) ListingModel.formatJarak(listing.jarakKm!),
      if (listing.kotaGudang != null && listing.kotaGudang!.isNotEmpty) listing.kotaGudang!,
    ];
    final bool diHargaMinimum = listing.hargaSekarang <= listing.hargaMinimum;
    final bool tampilHitungMundur =
        listing.status == 'active' && listing.waktuTurunBerikutnya != null && !diHargaMinimum;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                labelAtas.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.gayaLabelKapital,
              ),
            ),
            if (sisaHari != null) ...[
              const SizedBox(width: AppTheme.jarakKecil),
              Text(
                'Sisa $sisaHari hari',
                style: TextStyle(
                  fontSize: AppTheme.fontLabel,
                  fontWeight: FontWeight.w700,
                  // Amber = perlu segera dibeli (<= 14 hari), hijau = masih lama.
                  color: sisaHari <= 14 ? AppTheme.warnaSisaHari : AppTheme.warnaSukses,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppTheme.jarakMini / 2),
        Text(
          listing.namaProduk,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: AppTheme.fontSedang,
            fontWeight: FontWeight.w700,
            color: AppTheme.warnaTeks,
          ),
        ),
        const SizedBox(height: AppTheme.jarakMini),
        Wrap(
          spacing: AppTheme.jarakKecil,
          runSpacing: AppTheme.jarakMini / 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (tampilHitungMundur)
              PriceCountdown(
                waktuTurun: listing.waktuTurunBerikutnya!,
                onHargaTurun: onHargaTurun,
                ringkas: true,
              )
            else if (diHargaMinimum && listing.status == 'active')
              const ChipLembut(teks: 'harga minimum'),
            if (lokasi.isNotEmpty)
              Text(
                lokasi.join(' · '),
                style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksSedang),
              ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: AppTheme.jarakMini,
                children: [
                  Text(ListingModel.formatRupiah(listing.hargaSekarang), style: AppTheme.gayaHarga),
                  Text('/${listing.satuan}', style: AppTheme.gayaTeksRedup.copyWith(fontSize: AppTheme.fontLabel)),
                  Text(
                    ListingModel.formatRupiah(listing.hargaNormal),
                    style: AppTheme.gayaHargaCoret.copyWith(fontSize: AppTheme.fontLabel),
                  ),
                ],
              ),
            ),
            if (untukPenjual)
              StatusBadge(status: listing.status, label: listing.labelStatus)
            else
              TombolFavorit(favorit: FavoritModel.dariListing(listing)),
          ],
        ),
      ],
    );
  }
}

// Foto dari internet dengan pita diskon menempel di tepi kiri.
class _FotoProduk extends StatelessWidget {
  final String? urlGambar;
  final int diskonPersen;

  const _FotoProduk({required this.urlGambar, required this.diskonPersen});

  @override
  Widget build(BuildContext context) {
    const Widget fotoCadangan = ColoredBox(
      color: AppTheme.warnaLatarNetral,
      child: Center(
        child: Icon(Icons.inventory_2_outlined, size: AppTheme.ikonSedang, color: AppTheme.warnaTeksRedup),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusTombol),
      child: SizedBox(
        width: AppTheme.gambarKartu,
        height: AppTheme.gambarKartu,
        child: Stack(
          children: [
            Positioned.fill(
              child: (urlGambar == null || urlGambar!.isEmpty)
                  ? fotoCadangan
                  : Image.network(
                      urlGambar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => fotoCadangan,
                    ),
            ),
            if (diskonPersen > 0)
              Positioned(
                top: AppTheme.jarakKecil,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakMini, vertical: AppTheme.jarakMini / 2),
                  decoration: const BoxDecoration(
                    color: AppTheme.warnaAksen,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(AppTheme.radiusChip)),
                  ),
                  child: Text(
                    '-$diskonPersen%',
                    style: const TextStyle(
                      color: AppTheme.warnaPermukaan,
                      fontWeight: FontWeight.w800,
                      fontSize: AppTheme.fontLabel,
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
