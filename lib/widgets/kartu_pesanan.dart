import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/buyer/order_detail_screen.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'dialog_memuat.dart';
import 'kartu_pesanan_pembeli.dart';
import 'kartu_pesanan_penjual.dart';

// Kartu satu pesanan untuk Pembeli (T3) dan Penjual (T4). Berisi logika aksi
// (buka detail, ubah status, ingatkan pembeli); tampilannya ada di
// KartuPesananPembeli dan KartuPesananPenjual.
class KartuPesanan extends StatelessWidget {
  final OrderModel pesanan;
  final bool isPenjual;
  final VoidCallback? onKembali;

  const KartuPesanan({
    super.key,
    required this.pesanan,
    required this.isPenjual,
    this.onKembali,
  });

  Future<void> _bukaDetail(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(
          idPesanan: pesanan.id,
          isPenjual: isPenjual,
        ),
      ),
    );
    onKembali?.call();
  }

  Future<void> _ubahStatus(BuildContext context, String statusBaru) async {
    tampilkanDialogMemuat(context, pesan: 'Memperbarui status...');
    try {
      await ApiService.ubahStatusPesanan(pesanan.id, statusBaru);
      if (!context.mounted) return;
      Navigator.pop(context); // tutup dialog loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status pesanan berhasil diperbarui')),
      );
      onKembali?.call();
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // tutup dialog loading
      final String pesan = e.toString().replaceFirst('Exception: ', '');
      if (pesan == 'Sesi berakhir') {
        await kembaliKeLogin(context);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesan), backgroundColor: AppTheme.warnaGalat),
      );
    }
  }

  Future<void> _ingatkanPembeli(BuildContext context) async {
    tampilkanDialogMemuat(context, pesan: 'Mengirim pengingat ke pembeli...');
    try {
      await ApiService.ingatkanPembeli(pesanan.id);
      if (!context.mounted) return;
      Navigator.pop(context); // tutup dialog loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengingat pick-up berhasil dikirim ke pembeli')),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // tutup dialog loading
      final String pesan = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesan), backgroundColor: AppTheme.warnaGalat),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pembeli: kartu gaya Riwayat Transaksi Recovera lama.
    if (!isPenjual) {
      return KartuPesananPembeli(pesanan: pesanan, onBukaDetail: () => _bukaDetail(context));
    }
    // Penjual: kartu gaya Kelola Pesanan Masuk Recovera lama.
    return KartuPesananPenjual(
      pesanan: pesanan,
      onBukaDetail: () => _bukaDetail(context),
      onUbahStatus: (statusBaru) => _ubahStatus(context, statusBaru),
      onIngatkanPembeli: () => _ingatkanPembeli(context),
    );
  }
}
