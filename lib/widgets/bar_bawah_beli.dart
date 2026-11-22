import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'primary_button.dart';

// Bar bawah tetap (Sticky Bottom Bar) di halaman detail listing (T1).
// Menampilkan stepper jumlah pembelian (1..stok), perkiraan total harga,
// dan tombol Beli Sekarang.
class BarBawahBeli extends StatelessWidget {
  final ListingModel listing;
  final int jumlah;
  final ValueChanged<int> onJumlahDiubah;
  final VoidCallback onBeliDitekan;

  const BarBawahBeli({
    super.key,
    required this.listing,
    required this.jumlah,
    required this.onJumlahDiubah,
    required this.onBeliDitekan,
  });

  bool get _stokTersedia => listing.stok > 0;
  double get _totalPerkiraan => listing.hargaSekarang * jumlah;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.jarakSedang),
      decoration: BoxDecoration(
        color: AppTheme.warnaPermukaan,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: AppTheme.radius,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Baris atas: Info jumlah & Stepper [-] [ Qty ] [+]
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Jumlah Pembelian',
                        style: TextStyle(
                          fontSize: AppTheme.fontNormal,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.warnaTeks,
                        ),
                      ),
                      Text(
                        _stokTersedia
                            ? '(Min: 1 ${listing.satuan} | Stok: ${listing.stok})'
                            : 'Stok habis',
                        style: const TextStyle(
                          fontSize: AppTheme.fontKecil,
                          color: AppTheme.warnaTeksRedup,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_stokTersedia)
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.warnaLatar,
                      borderRadius: BorderRadius.circular(AppTheme.radius / 2),
                      border: Border.all(color: AppTheme.warnaGaris),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          onPressed: jumlah > 1 ? () => onJumlahDiubah(jumlah - 1) : null,
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 36),
                          alignment: Alignment.center,
                          child: Text(
                            '$jumlah',
                            style: const TextStyle(
                              fontSize: AppTheme.fontNormal,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.warnaTeks,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          onPressed: jumlah < listing.stok ? () => onJumlahDiubah(jumlah + 1) : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.jarakKecil),
            // Baris bawah: Total & Tombol Beli
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Perkiraan total',
                        style: TextStyle(
                          fontSize: AppTheme.fontKecil,
                          color: AppTheme.warnaTeksRedup,
                        ),
                      ),
                      Text(
                        ListingModel.formatRupiah(_totalPerkiraan),
                        style: AppTheme.gayaHarga,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.jarakSedang),
                Expanded(
                  child: PrimaryButton(
                    teks: _stokTersedia ? 'Beli Sekarang' : 'Stok Habis',
                    onPressed: _stokTersedia ? onBeliDitekan : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
