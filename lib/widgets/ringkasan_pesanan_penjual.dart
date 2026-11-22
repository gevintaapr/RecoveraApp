import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../theme/app_theme.dart';

// Kotak ringkasan pesanan penjual di layar Kelola Pesanan Masuk (T4).
// Menampilkan metrik cepat: Menunggu disiapkan, Siap diambil, dan Selesai.
class RingkasanPesananPenjual extends StatelessWidget {
  final List<OrderModel> daftarPesanan;

  const RingkasanPesananPenjual({super.key, required this.daftarPesanan});

  @override
  Widget build(BuildContext context) {
    final int menunggu =
        daftarPesanan.where((o) => o.status == 'paid').length;
    final int siapDiambil =
        daftarPesanan.where((o) => o.status == 'in_progress').length;
    final int selesai =
        daftarPesanan.where((o) => o.status == 'completed').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
      child: Row(
        children: [
          Expanded(
            child: _kartuRingkas(
              label: 'Menunggu',
              jumlah: menunggu,
              ikon: Icons.hourglass_top_rounded,
              warnaIkon: AppTheme.warnaAksen,
            ),
          ),
          const SizedBox(width: AppTheme.jarakKecil),
          Expanded(
            child: _kartuRingkas(
              label: 'Siap Ambil',
              jumlah: siapDiambil,
              ikon: Icons.storefront_outlined,
              warnaIkon: AppTheme.warnaUtama,
            ),
          ),
          const SizedBox(width: AppTheme.jarakKecil),
          Expanded(
            child: _kartuRingkas(
              label: 'Selesai',
              jumlah: selesai,
              ikon: Icons.check_circle_outline,
              warnaIkon: AppTheme.warnaTeksRedup,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuRingkas({
    required String label,
    required int jumlah,
    required IconData ikon,
    required Color warnaIkon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.jarakKecil),
      decoration: BoxDecoration(
        color: AppTheme.warnaPermukaan,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.warnaGaris),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$jumlah',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.warnaTeks,
                ),
              ),
              Icon(ikon, size: 20, color: warnaIkon),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTheme.fontKecil,
              color: AppTheme.warnaTeksRedup,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

