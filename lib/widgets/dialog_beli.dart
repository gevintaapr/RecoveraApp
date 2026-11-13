import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';

// Dialog konfirmasi Beli Sekarang: pilih jumlah, lihat perkiraan total.
// Hasil dikirim balik lewat Navigator.pop(context, jumlah) (Modul IV: pop + data).
// Batal -> Navigator.pop(context) -> hasilnya null.
//
// Cara pakai:  final int? jumlah = await tampilkanDialogBeli(context, listing);
Future<int?> tampilkanDialogBeli(BuildContext context, ListingModel listing) {
  return showDialog<int>(
    context: context,
    builder: (context) => _DialogBeli(listing: listing),
  );
}

class _DialogBeli extends StatefulWidget {
  final ListingModel listing;

  const _DialogBeli({required this.listing});

  @override
  State<_DialogBeli> createState() => _DialogBeliState();
}

class _DialogBeliState extends State<_DialogBeli> {
  int jumlah = 1;

  @override
  Widget build(BuildContext context) {
    final ListingModel listing = widget.listing;
    final double perkiraanTotal = listing.hargaSekarang * jumlah;

    return AlertDialog(
      title: const Text('Beli Sekarang'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(listing.namaProduk, style: AppTheme.gayaSubjudul),
          const SizedBox(height: AppTheme.jarakKecil),
          Text('${ListingModel.formatRupiah(listing.hargaSekarang)} / ${listing.satuan}'),
          const SizedBox(height: AppTheme.jarakSedang),
          Row(
            children: [
              const Text('Jumlah'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: jumlah > 1 ? () => setState(() => jumlah--) : null,
              ),
              Text('$jumlah', style: AppTheme.gayaSubjudul),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: jumlah < listing.stok ? () => setState(() => jumlah++) : null,
              ),
            ],
          ),
          Text('Stok tersedia: ${listing.stok} ${listing.satuan}', style: AppTheme.gayaTeksRedup),
          const Divider(height: AppTheme.jarakBesar),
          Text('Perkiraan total', style: AppTheme.gayaTeksRedup),
          Text(ListingModel.formatRupiah(perkiraanTotal), style: AppTheme.gayaHarga),
          const SizedBox(height: AppTheme.jarakKecil),
          const Text(
            'Harga final dikunci server saat pembelian diproses.',
            style: TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, jumlah),
          child: const Text('Beli'),
        ),
      ],
    );
  }
}
