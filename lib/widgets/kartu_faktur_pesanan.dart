import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

// Kartu "Faktur Transaksi B2B" (sheet faktur Recovera lama): judul + status,
// nomor pesanan, rincian baris, lalu Total Pembayaran besar.
class KartuFakturPesanan extends StatelessWidget {
  final OrderModel pesanan;

  const KartuFakturPesanan({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppTheme.jarakBesar, AppTheme.jarakTepi, AppTheme.jarakBesar, AppTheme.jarakBesar),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Faktur Transaksi B2B',
                    style: TextStyle(fontSize: AppTheme.fontJudulTransaksi, fontWeight: FontWeight.w800, color: AppTheme.warnaJudulKartu),
                  ),
                ),
                StatusBadge(status: pesanan.status, label: pesanan.labelStatus),
              ],
            ),
            const SizedBox(height: AppTheme.jarakMini),
            Text(
              'ID: #${pesanan.id} • ${ListingModel.formatTanggal(pesanan.dibuatPada)}, ${ListingModel.formatJam(pesanan.dibuatPada)}',
              style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup),
            ),
            const Divider(height: AppTheme.jarakBesar + AppTheme.jarakMini),
            _BarisFaktur(judul: 'Produk', nilai: pesanan.namaProduk),
            _BarisFaktur(judul: 'Jumlah / Qty', nilai: '${pesanan.jumlah}'),
            _BarisFaktur(judul: 'Harga Satuan', nilai: ListingModel.formatRupiah(pesanan.hargaSatuan)),
            const _BarisFaktur(judul: 'Biaya Penanganan Platform', nilai: 'Rp 0 (Subsidi B2B)'),
            const Divider(height: AppTheme.jarakBesar + AppTheme.jarakMini),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total Pembayaran',
                    style: TextStyle(fontSize: AppTheme.fontSedang, fontWeight: FontWeight.w800, color: AppTheme.warnaJudulKartu),
                  ),
                ),
                Text(
                  ListingModel.formatRupiah(pesanan.totalHarga),
                  style: const TextStyle(fontSize: AppTheme.fontJudulTransaksi, fontWeight: FontWeight.w900, color: AppTheme.warnaUtama),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Satu baris "judul ...... nilai" di faktur (_buildInvoiceLine lama).
class _BarisFaktur extends StatelessWidget {
  final String judul;
  final String nilai;

  const _BarisFaktur({required this.judul, required this.nilai});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.jarakMini),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(judul, style: const TextStyle(fontSize: AppTheme.fontInput, color: AppTheme.warnaTeksRedup)),
          const SizedBox(width: AppTheme.jarakSedang),
          Expanded(
            child: Text(
              nilai,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: AppTheme.fontInput, fontWeight: FontWeight.w600, color: AppTheme.warnaJudulKartu),
            ),
          ),
        ],
      ),
    );
  }
}
