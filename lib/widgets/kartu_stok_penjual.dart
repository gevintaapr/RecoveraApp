import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

// Kartu satu stok di tab Stok penjual (_buildInventoryCard Recovera lama):
// foto 72 + nama + jumlah + harga/satuan; pil sisa hari & pil status;
// banner "Proses Saat Ini" berisi status listing.
class KartuStokPenjual extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const KartuStokPenjual({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final int? sisa = listing.sisaHari;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.jarakSedang),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusKartuStok),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusKartuStok),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(AppTheme.jarakTepi),
            decoration: BoxDecoration(
              color: AppTheme.warnaPermukaan,
              borderRadius: BorderRadius.circular(AppTheme.radiusKartuStok),
              border: Border.all(color: AppTheme.warnaGaris),
              boxShadow: const [BoxShadow(color: AppTheme.warnaBayanganKartu, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Foto(urlGambar: listing.urlGambar),
                    const SizedBox(width: AppTheme.jarakInput),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.namaProduk,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: AppTheme.fontNamaStok, fontWeight: FontWeight.w800, color: AppTheme.warnaNavy),
                          ),
                          const SizedBox(height: AppTheme.jarakMini),
                          Text(
                            '${listing.stok} ${listing.satuan}',
                            style: const TextStyle(fontSize: AppTheme.fontSedang, fontWeight: FontWeight.w500, color: AppTheme.warnaTeksRedup),
                          ),
                          const SizedBox(height: AppTheme.jarakLabel),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  ListingModel.formatRupiah(listing.hargaSekarang),
                                  style: const TextStyle(fontSize: AppTheme.fontSubjudul, fontWeight: FontWeight.w800, color: AppTheme.warnaJarak),
                                ),
                                Text(' / ${listing.satuan}', style: const TextStyle(fontSize: AppTheme.fontSedang, color: AppTheme.warnaTeksRedup)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.jarakInput),
                Row(
                  children: [
                    if (sisa != null) ...[
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.radiusSedang, vertical: AppTheme.jarakMini),
                          decoration: BoxDecoration(
                            color: AppTheme.warnaLatarKedaluwarsa,
                            borderRadius: BorderRadius.circular(AppTheme.radiusKapsul),
                            border: Border.all(color: AppTheme.warnaGarisKedaluwarsa),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time_rounded, size: AppTheme.ikonCentang, color: AppTheme.warnaSisaSedang),
                              const SizedBox(width: AppTheme.jarakMini),
                              Flexible(
                                child: Text(
                                  sisa <= 0 ? 'Sudah kedaluwarsa' : 'Sisa $sisa hari lagi',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: AppTheme.fontInput, fontWeight: FontWeight.w600, color: AppTheme.warnaSisaSedang),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.jarakKecil),
                    ],
                    StatusBadge(status: listing.status, label: listing.labelStatus),
                  ],
                ),
                const SizedBox(height: AppTheme.jarakSedang),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakInput, vertical: AppTheme.radiusSedang),
                  decoration: BoxDecoration(
                    color: AppTheme.warnaLatar,
                    borderRadius: BorderRadius.circular(AppTheme.radiusTombol),
                    border: Border.all(color: AppTheme.warnaLatarNetral),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: AppTheme.jarakLabel,
                        height: AppTheme.jarakLabel,
                        decoration: const BoxDecoration(color: AppTheme.warnaJarak, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: AppTheme.jarakKecil),
                      const Text(
                        'Proses Saat Ini:',
                        style: TextStyle(fontSize: AppTheme.fontInput, fontWeight: FontWeight.w500, color: AppTheme.warnaTeksRedup),
                      ),
                      const SizedBox(width: AppTheme.jarakLabel),
                      Expanded(
                        child: Text(
                          listing.labelStatus,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: AppTheme.fontInput, fontWeight: FontWeight.w700, color: AppTheme.warnaJarak),
                        ),
                      ),
                    ],
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

class _Foto extends StatelessWidget {
  final String? urlGambar;

  const _Foto({required this.urlGambar});

  @override
  Widget build(BuildContext context) {
    const Widget cadangan = ColoredBox(
      color: AppTheme.warnaLatarInfo,
      child: Center(child: Icon(Icons.inventory_2_rounded, color: AppTheme.warnaJarak, size: AppTheme.ikonSedang)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.jarakInput),
      child: SizedBox(
        width: AppTheme.fotoStok,
        height: AppTheme.fotoStok,
        child: (urlGambar == null || urlGambar!.isEmpty)
            ? cadangan
            : Image.network(urlGambar!, fit: BoxFit.cover, errorBuilder: (c, e, s) => cadangan),
      ),
    );
  }
}
