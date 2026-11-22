import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'primary_button.dart';

// Bottom sheet konfirmasi pesanan lelang (T1).
// Menampilkan ringkasan produk, jumlah, harga satuan saat ini, total,
// dan catatan bahwa harga dikunci server saat transaksi diproses.
Future<bool?> tampilkanSheetKonfirmasiBeli({
  required BuildContext context,
  required ListingModel listing,
  required int jumlah,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _SheetKonfirmasiBeli(
      listing: listing,
      jumlah: jumlah,
    ),
  );
}

class _SheetKonfirmasiBeli extends StatelessWidget {
  final ListingModel listing;
  final int jumlah;

  const _SheetKonfirmasiBeli({
    required this.listing,
    required this.jumlah,
  });

  @override
  Widget build(BuildContext context) {
    final double totalHarga = listing.hargaSekarang * jumlah;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.warnaPermukaan,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius * 2)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppTheme.jarakSedang,
        AppTheme.jarakKecil,
        AppTheme.jarakSedang,
        MediaQuery.of(context).viewInsets.bottom + AppTheme.jarakBesar,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppTheme.jarakSedang),
              decoration: BoxDecoration(
                color: AppTheme.warnaGaris,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KONFIRMASI PESANAN',
                    style: TextStyle(
                      fontSize: AppTheme.fontKecil,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warnaTeksRedup,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Lock-In Dutch Auction',
                    style: TextStyle(
                      fontSize: AppTheme.fontSubjudul,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warnaTeks,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.warnaTeksRedup),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.jarakSedang),
          // Ringkasan Pembelian
          Container(
            padding: const EdgeInsets.all(AppTheme.jarakSedang),
            decoration: BoxDecoration(
              color: AppTheme.warnaLatar,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.warnaGaris),
            ),
            child: Column(
              children: [
                _barisRingkasan('Produk', listing.namaProduk),
                const SizedBox(height: AppTheme.jarakKecil),
                _barisRingkasan('Jumlah', '$jumlah ${listing.satuan}'),
                const SizedBox(height: AppTheme.jarakKecil),
                _barisRingkasan(
                  'Harga Satuan Terkini',
                  ListingModel.formatRupiah(listing.hargaSekarang),
                ),
                const Divider(height: AppTheme.jarakSedang * 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Perkiraan',
                      style: TextStyle(
                        fontSize: AppTheme.fontNormal,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.warnaTeks,
                      ),
                    ),
                    Text(
                      ListingModel.formatRupiah(totalHarga),
                      style: AppTheme.gayaHarga,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.jarakSedang),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.info_outline, size: 16, color: AppTheme.warnaAksen),
              SizedBox(width: AppTheme.jarakKecil),
              Expanded(
                child: Text(
                  'Harga final dikunci server pada detik transaksi berhasil diproses.',
                  style: TextStyle(
                    fontSize: AppTheme.fontKecil,
                    color: AppTheme.warnaTeksRedup,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.jarakBesar),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppTheme.tinggiTombol),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: AppTheme.jarakSedang),
              Expanded(
                child: PrimaryButton(
                  teks: 'Konfirmasi Beli',
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barisRingkasan(String label, String nilai) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTheme.fontNormal,
            color: AppTheme.warnaTeksRedup,
          ),
        ),
        Text(
          nilai,
          style: const TextStyle(
            fontSize: AppTheme.fontNormal,
            fontWeight: FontWeight.w600,
            color: AppTheme.warnaTeks,
          ),
        ),
      ],
    );
  }
}

