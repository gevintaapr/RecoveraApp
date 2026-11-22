import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';

// Dua kartu ringkasan di layar Kelola Pesanan Masuk penjual (_buildSellerSummaryCards
// Recovera lama): TOTAL PENDAPATAN (jumlah total pesanan selesai) dan
// TOTAL PENJUALAN (jumlah pesanan). Semua angka dihitung dari daftar pesanan server.
class RingkasanPesananPenjual extends StatelessWidget {
  final List<OrderModel> daftarPesanan;

  const RingkasanPesananPenjual({super.key, required this.daftarPesanan});

  @override
  Widget build(BuildContext context) {
    final List<OrderModel> selesai = daftarPesanan.where((o) => o.status == 'completed').toList();
    final double pendapatan = selesai.fold(0, (total, o) => total + o.totalHarga);
    final int menunggu = daftarPesanan.where((o) => o.status == 'paid').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakTepi),
      child: Row(
        children: [
          Expanded(
            child: _KartuRingkasan(
              label: 'TOTAL PENDAPATAN',
              nilai: ListingModel.formatRupiah(pendapatan),
              keterangan: 'dari ${selesai.length} pesanan selesai',
              ikon: Icons.payments_rounded,
              warnaIkon: AppTheme.warnaSisaAman,
              warnaLatarIkon: AppTheme.warnaLatarStok,
            ),
          ),
          const SizedBox(width: AppTheme.jarakSedang),
          Expanded(
            child: _KartuRingkasan(
              label: 'TOTAL PENJUALAN',
              nilai: '${daftarPesanan.length} pesanan',
              keterangan: '$menunggu menunggu disiapkan',
              ikon: Icons.inventory_2_rounded,
              warnaIkon: AppTheme.warnaJarak,
              warnaLatarIkon: AppTheme.warnaLatarInfo,
            ),
          ),
        ],
      ),
    );
  }
}

class _KartuRingkasan extends StatelessWidget {
  final String label;
  final String nilai;
  final String keterangan;
  final IconData ikon;
  final Color warnaIkon;
  final Color warnaLatarIkon;

  const _KartuRingkasan({
    required this.label,
    required this.nilai,
    required this.keterangan,
    required this.ikon,
    required this.warnaIkon,
    required this.warnaLatarIkon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.jarakInput),
      decoration: BoxDecoration(
        color: AppTheme.warnaPermukaan,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.warnaGaris),
        boxShadow: const [BoxShadow(color: AppTheme.warnaBayanganKartu, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppTheme.fontLabel,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warnaTeksRedup,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.jarakMini),
              Container(
                padding: const EdgeInsets.all(AppTheme.jarakLabel),
                decoration: BoxDecoration(color: warnaLatarIkon, borderRadius: BorderRadius.circular(AppTheme.radiusChip)),
                child: Icon(ikon, size: AppTheme.ikonKecil, color: warnaIkon),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.jarakLabel),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              nilai,
              style: const TextStyle(fontSize: AppTheme.fontSubjudul, fontWeight: FontWeight.w900, color: AppTheme.warnaNavy),
            ),
          ),
          const SizedBox(height: AppTheme.jarakMini),
          Text(
            keterangan,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w600, color: AppTheme.warnaTeksRedup),
          ),
        ],
      ),
    );
  }
}
