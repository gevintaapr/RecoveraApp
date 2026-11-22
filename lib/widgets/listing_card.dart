import 'package:flutter/material.dart';

import '../models/favorit_model.dart';
import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'foto_kartu_produk.dart';
import 'price_countdown.dart';
import 'status_badge.dart';
import 'tombol_favorit.dart';

// Kartu satu listing (ProductCard Recovera lama), dipakai Beranda pembeli & Stok penjual:
// - kiri: foto 88 + pita diskon merah + badge beku/dingin
// - tengah: NAMA PERUSAHAAN, nama produk, merek, hitung mundur harga, jarak • kota, harga
// - kanan: "Sisa X Hari" (warna sesuai urgensi), lalu hati + panah (pembeli)
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
      padding: const EdgeInsets.only(bottom: AppTheme.jarakSedang),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: AppTheme.warnaPermukaan,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.warnaGaris),
              boxShadow: const [
                BoxShadow(color: AppTheme.warnaBayanganKartu, blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            padding: const EdgeInsets.all(AppTheme.jarakSedang),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hati favorit menempel di pojok kanan bawah foto, supaya kolom kanan
                  // hanya berisi panah seperti kartu lama dan nama produk tidak terpotong.
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      FotoKartuProduk(
                        urlGambar: listing.urlGambar,
                        diskonPersen: listing.diskonPersen,
                        jenisPenyimpanan: listing.jenisPenyimpanan,
                      ),
                      if (!untukPenjual)
                        Positioned(
                          right: -AppTheme.jarakKecil,
                          bottom: -AppTheme.jarakKecil,
                          child: TombolFavorit(favorit: FavoritModel.dariListing(listing), bulat: true),
                        ),
                    ],
                  ),
                  const SizedBox(width: AppTheme.jarakSedang),
                  Expanded(child: _InfoTengah(listing: listing, untukPenjual: untukPenjual, onHargaTurun: onHargaTurun)),
                  const SizedBox(width: AppTheme.jarakKecil),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TeksSisaHari(sisaHari: listing.sisaHari),
                      if (untukPenjual)
                        StatusBadge(status: listing.status, label: listing.labelStatus)
                      else
                        _TombolPanah(onTap: onTap),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTengah extends StatelessWidget {
  final ListingModel listing;
  final bool untukPenjual;
  final VoidCallback? onHargaTurun;

  const _InfoTengah({required this.listing, required this.untukPenjual, this.onHargaTurun});

  @override
  Widget build(BuildContext context) {
    final String labelAtas = untukPenjual ? 'Stok ${listing.stok} ${listing.satuan}' : (listing.namaPenjual ?? '');
    final bool tampilHitungMundur = listing.status == 'active' &&
        listing.waktuTurunBerikutnya != null &&
        listing.hargaSekarang > listing.hargaMinimum;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labelAtas.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppTheme.fontMini,
                fontWeight: FontWeight.w700,
                color: AppTheme.warnaTeksRedup,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppTheme.jarakTipis),
            Text(
              listing.namaProduk,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppTheme.fontInput,
                fontWeight: FontWeight.w700,
                color: AppTheme.warnaJudulKartu,
                height: 1.25,
              ),
            ),
            if (listing.merek != null && listing.merek!.isNotEmpty)
              Text(
                listing.merek!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup),
              ),
            if (tampilHitungMundur) ...[
              const SizedBox(height: AppTheme.jarakMini),
              PriceCountdown(waktuTurun: listing.waktuTurunBerikutnya!, onHargaTurun: onHargaTurun, ringkas: true),
            ],
          ],
        ),
        const SizedBox(height: AppTheme.jarakMini),
        if (listing.jarakKm != null || listing.kotaGudang != null)
          Row(
            children: [
              if (listing.jarakKm != null) ...[
                const Icon(Icons.near_me_outlined, size: AppTheme.fontKecil, color: AppTheme.warnaJarak),
                const SizedBox(width: AppTheme.jarakTipis),
                Text(
                  ListingModel.formatJarak(listing.jarakKm!),
                  style: const TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w600, color: AppTheme.warnaJarak),
                ),
                const Text('  •  ', style: TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup)),
              ],
              Flexible(
                child: Text(
                  listing.kotaGudang ?? '-',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup),
                ),
              ),
            ],
          ),
        const SizedBox(height: AppTheme.jarakMini),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                ListingModel.formatRupiah(listing.hargaSekarang),
                style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w800, color: AppTheme.warnaUtama),
              ),
              const SizedBox(width: AppTheme.jarakMini),
              Text(
                '/ ${listing.satuan}',
                style: const TextStyle(fontSize: AppTheme.fontMini, fontWeight: FontWeight.w500, color: AppTheme.warnaTeksRedup),
              ),
              const SizedBox(width: AppTheme.jarakMini),
              Text(
                ListingModel.formatRupiah(listing.hargaNormal),
                style: const TextStyle(
                  fontSize: AppTheme.fontMini,
                  color: AppTheme.warnaTeksRedup,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// "Sisa X Hari" tanpa latar, warnanya menandai urgensi (seperti _ExpiryBadge lama).
class _TeksSisaHari extends StatelessWidget {
  final int? sisaHari;

  const _TeksSisaHari({required this.sisaHari});

  @override
  Widget build(BuildContext context) {
    if (sisaHari == null) return const SizedBox.shrink();
    final int hari = sisaHari!;
    final Color warna = hari <= 3
        ? AppTheme.warnaSisaMendesak
        : (hari <= 7 ? AppTheme.warnaSisaSedang : AppTheme.warnaSisaAman);
    return Text(
      hari <= 0 ? 'Sudah Kedaluwarsa' : 'Sisa $hari Hari',
      style: TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w600, color: warna),
    );
  }
}

// Tombol kotak biru berpanah untuk membuka detail. Terlihat 28, area ketuk 44.
class _TombolPanah extends StatelessWidget {
  final VoidCallback onTap;

  const _TombolPanah({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Lihat detail',
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: AppTheme.ukuranTombolIkon, minHeight: AppTheme.ukuranTombolIkon),
      icon: Container(
        width: AppTheme.tombolPanah,
        height: AppTheme.tombolPanah,
        decoration: BoxDecoration(color: AppTheme.warnaUtama, borderRadius: BorderRadius.circular(AppTheme.radiusSedang)),
        child: const Icon(Icons.arrow_forward_rounded, color: AppTheme.warnaPermukaan, size: AppTheme.ikonPanah),
      ),
    );
  }
}
