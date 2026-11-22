import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../theme/app_theme.dart';
import 'kartu_angka.dart';

// Tiga kotak angka di layar Pesanan masuk penjual (T4): Menunggu, Siap ambil,
// Selesai. Angkanya dihitung dari daftar pesanan asli dari server.
class RingkasanPesananPenjual extends StatelessWidget {
  final List<OrderModel> daftarPesanan;

  const RingkasanPesananPenjual({super.key, required this.daftarPesanan});

  int _hitung(String status) => daftarPesanan.where((o) => o.status == status).length;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
      child: Row(
        children: [
          Expanded(
            child: KartuAngka(label: 'Menunggu', nilai: '${_hitung('paid')}', warnaNilai: AppTheme.warnaAksen),
          ),
          const SizedBox(width: AppTheme.jarakKecil),
          Expanded(
            child: KartuAngka(label: 'Siap ambil', nilai: '${_hitung('in_progress')}', warnaNilai: AppTheme.warnaUtama),
          ),
          const SizedBox(width: AppTheme.jarakKecil),
          Expanded(
            child: KartuAngka(label: 'Selesai', nilai: '${_hitung('completed')}', warnaNilai: AppTheme.warnaSukses),
          ),
        ],
      ),
    );
  }
}
