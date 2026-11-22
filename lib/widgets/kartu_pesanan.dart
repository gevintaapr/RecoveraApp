import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../models/order_model.dart';
import '../screens/buyer/order_detail_screen.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

// Kartu satu pesanan. Dipakai di daftar pesanan (kedua peran) dan Dasbor penjual.
// Ketuk -> detail pesanan; penjual bisa mengubah status di sana.
class KartuPesanan extends StatelessWidget {
  final OrderModel pesanan;
  final bool isPenjual;
  final VoidCallback? onKembali; // dipanggil setelah kembali dari detail (untuk muat ulang)

  const KartuPesanan({super.key, required this.pesanan, required this.isPenjual, this.onKembali});

  @override
  Widget build(BuildContext context) {
    // Penjual melihat nama pembeli, pembeli melihat nama penjual.
    final String? pihakLain = isPenjual ? pesanan.namaPembeli : pesanan.namaPenjual;

    return Card(
      color: AppTheme.warnaPermukaan,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: ListTile(
        title: Text(pesanan.namaProduk, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${pesanan.jumlah} x ${ListingModel.formatRupiah(pesanan.hargaSatuan)}'
          '${pihakLain == null ? '' : '\n$pihakLain'}\n'
          '${ListingModel.formatTanggal(pesanan.dibuatPada)}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(ListingModel.formatRupiah(pesanan.totalHarga), style: AppTheme.gayaHarga),
            const SizedBox(height: AppTheme.jarakKecil / 2),
            StatusBadge(status: pesanan.status, label: pesanan.labelStatus),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(idPesanan: pesanan.id, isPenjual: isPenjual),
            ),
          );
          onKembali?.call();
        },
      ),
    );
  }
}
