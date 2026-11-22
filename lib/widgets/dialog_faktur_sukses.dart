import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';

// Dialog faktur ringkas setelah berhasil Beli Sekarang (T1).
// Menampilkan nomor pesanan, detail harga final terkunci, dan opsi
// membuka halaman detail pesanan atau menutup dialog.
Future<void> tampilkanDialogFakturSukses({
  required BuildContext context,
  required OrderModel pesanan,
  required ListingModel listing,
  required VoidCallback onLihatPesanan,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _DialogFakturSukses(
      pesanan: pesanan,
      listing: listing,
      onLihatPesanan: onLihatPesanan,
    ),
  );
}

class _DialogFakturSukses extends StatelessWidget {
  final OrderModel pesanan;
  final ListingModel listing;
  final VoidCallback onLihatPesanan;

  const _DialogFakturSukses({
    required this.pesanan,
    required this.listing,
    required this.onLihatPesanan,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius * 1.5),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.jarakKecil),
            decoration: BoxDecoration(
              color: AppTheme.warnaUtama.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.warnaUtama,
              size: 28,
            ),
          ),
          const SizedBox(width: AppTheme.jarakKecil),
          const Expanded(
            child: Text(
              'Lelang Berhasil Dikunci!',
              style: TextStyle(
                fontSize: AppTheme.fontSubjudul,
                fontWeight: FontWeight.bold,
                color: AppTheme.warnaTeks,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pesanan likuidasi pangan Anda telah berhasil dibuat dan dikunci di server.',
            style: TextStyle(
              fontSize: AppTheme.fontKecil,
              color: AppTheme.warnaTeksRedup,
            ),
          ),
          const SizedBox(height: AppTheme.jarakSedang),
          Container(
            padding: const EdgeInsets.all(AppTheme.jarakSedang),
            decoration: BoxDecoration(
              color: AppTheme.warnaLatar,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.warnaGaris),
            ),
            child: Column(
              children: [
                _barisFaktur('ID Pesanan', '#${pesanan.id}'),
                const SizedBox(height: AppTheme.jarakKecil),
                _barisFaktur('Produk', pesanan.namaProduk),
                const SizedBox(height: AppTheme.jarakKecil),
                _barisFaktur('Jumlah', '${pesanan.jumlah} ${listing.satuan}'),
                const SizedBox(height: AppTheme.jarakKecil),
                _barisFaktur(
                  'Harga Final',
                  ListingModel.formatRupiah(pesanan.hargaSatuan),
                ),
                const Divider(height: AppTheme.jarakSedang),
                _barisFaktur(
                  'Total Tagihan',
                  ListingModel.formatRupiah(pesanan.totalHarga),
                  tebal: true,
                ),
                const SizedBox(height: AppTheme.jarakKecil),
                _barisFaktur(
                  'Lokasi Ambil',
                  '${listing.namaPenjual ?? '-'}\n${listing.kotaGudang ?? '-'}',
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onLihatPesanan();
          },
          child: const Text('Lihat Pesanan'),
        ),
      ],
    );
  }

  Widget _barisFaktur(String label, String nilai, {bool tebal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTheme.fontKecil,
            color: AppTheme.warnaTeksRedup,
          ),
        ),
        const SizedBox(width: AppTheme.jarakKecil),
        Flexible(
          child: Text(
            nilai,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: AppTheme.fontKecil,
              fontWeight: tebal ? FontWeight.bold : FontWeight.w600,
              color: tebal ? AppTheme.warnaUtama : AppTheme.warnaTeks,
            ),
          ),
        ),
      ],
    );
  }
}
