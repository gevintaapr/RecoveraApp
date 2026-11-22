import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'chip_lembut.dart';

// Baris ringkas stok yang segera kedaluwarsa (<= 14 hari) di Dasbor penjual (T5):
// nama, stok + sisa hari di kiri; harga sekarang + harga minimum di kanan.
class KartuStokKedaluwarsa extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const KartuStokKedaluwarsa({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.jarakKecil),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.jarakSedang),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.namaProduk,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppTheme.jarakMini / 2),
                      Wrap(
                        spacing: AppTheme.jarakKecil,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${listing.stok} ${listing.satuan}',
                            style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup),
                          ),
                          ChipLembut(
                            teks: 'sisa ${listing.sisaHari ?? 0} hari',
                            warnaLatar: AppTheme.warnaLatarPeringatan,
                            warnaTeks: AppTheme.warnaTeksPeringatan,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ListingModel.formatRupiah(listing.hargaSekarang),
                      style: AppTheme.gayaHarga.copyWith(fontSize: AppTheme.fontSedang),
                    ),
                    Text(
                      'min ${ListingModel.formatRupiah(listing.hargaMinimum)}',
                      style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
