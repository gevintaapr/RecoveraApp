import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';

// Satu baris stok yang segera kedaluwarsa di Dasbor penjual (_NearExpiryItemCard
// Recovera lama): kotak ikon berwarna, nama + jumlah, pil sisa hari.
// Warna: <= 3 hari merah, <= 7 hari amber, lainnya hijau (semua teks putih lolos 4.5:1).
class KartuStokKedaluwarsa extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const KartuStokKedaluwarsa({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final int sisa = listing.sisaHari ?? 0;
    final Color warna = sisa <= 3
        ? AppTheme.warnaSisaMendesak
        : (sisa <= 7 ? AppTheme.warnaSisaSedang : AppTheme.warnaSisaAman);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSedang),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.jarakMini),
        child: Row(
          children: [
            Container(
              width: AppTheme.kotakIkonStok,
              height: AppTheme.kotakIkonStok,
              decoration: BoxDecoration(
                color: warna.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSedang),
                border: Border.all(color: warna.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.inventory_2_rounded, size: AppTheme.ikonNav, color: warna),
            ),
            const SizedBox(width: AppTheme.jarakSedang),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.namaProduk,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w600, color: AppTheme.warnaNavy),
                  ),
                  const SizedBox(height: AppTheme.jarakTipis),
                  Text(
                    '${listing.stok} ${listing.satuan} • ${ListingModel.formatRupiah(listing.hargaSekarang)}',
                    style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakKecil, vertical: AppTheme.jarakMini),
              decoration: BoxDecoration(color: warna, borderRadius: BorderRadius.circular(AppTheme.radiusKapsul)),
              child: Text(
                sisa <= 0 ? 'Kedaluwarsa' : '$sisa hari lagi',
                style: const TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w700, color: AppTheme.warnaPermukaan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
