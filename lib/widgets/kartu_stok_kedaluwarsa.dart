import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';

// Kartu mini untuk stok yang mendekati kedaluwarsa (<= 14 hari) di Dasbor Penjual (T5).
class KartuStokKedaluwarsa extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const KartuStokKedaluwarsa({
    super.key,
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int sisaHari = listing.sisaHari ?? 0;

    return Card(
      color: AppTheme.warnaPermukaan,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: const BorderSide(color: AppTheme.warnaGaris),
      ),
      margin: const EdgeInsets.only(bottom: AppTheme.jarakKecil),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.jarakKecil),
          child: Row(
            children: [
              // Gambar mini
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radius / 2),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: (listing.urlGambar == null ||
                          listing.urlGambar!.isEmpty)
                      ? Container(
                          color: AppTheme.warnaGaris,
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 24,
                            color: AppTheme.warnaTeksRedup,
                          ),
                        )
                      : Image.network(
                          listing.urlGambar!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppTheme.warnaGaris,
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              size: 24,
                              color: AppTheme.warnaTeksRedup,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppTheme.jarakKecil),

              // Info Nama & Stok
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.namaProduk,
                      style: const TextStyle(
                        fontSize: AppTheme.fontNormal,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warnaTeks,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sisa stok: ${listing.stok} ${listing.satuan}',
                      style: const TextStyle(
                        fontSize: AppTheme.fontKecil,
                        color: AppTheme.warnaTeksRedup,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge Sisa Hari & Aksi
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warnaGalat.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(
                        color: AppTheme.warnaGalat.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Sisa $sisaHari Hari',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.warnaGalat,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppTheme.warnaTeksRedup,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

