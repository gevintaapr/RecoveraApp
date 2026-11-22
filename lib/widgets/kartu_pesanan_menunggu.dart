import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../screens/auth/login_screen.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'dialog_memuat.dart';

// Kartu "Pesanan Menunggu Tindakan" di Dasbor penjual (_buildPendingOrdersCard lama):
// maksimal 5 baris pesanan; tombol teks "Siapkan" (paid -> in_progress) atau
// "Selesaikan" (in_progress -> completed); "Lihat semua" bila lebih dari 5.
class KartuPesananMenunggu extends StatelessWidget {
  final List<OrderModel> daftarPesanan;
  final VoidCallback onBerubah; // muat ulang dasbor setelah status diubah
  final VoidCallback onLihatSemua;

  const KartuPesananMenunggu({super.key, required this.daftarPesanan, required this.onBerubah, required this.onLihatSemua});

  Future<void> _ubahStatus(BuildContext context, OrderModel pesanan) async {
    tampilkanDialogMemuat(context, pesan: 'Memperbarui status...');
    try {
      await ApiService.ubahStatusPesanan(pesanan.id, pesanan.status == 'paid' ? 'in_progress' : 'completed');
      if (!context.mounted) return;
      Navigator.pop(context); // tutup dialog loading
      onBerubah();
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      final String pesan = e.toString().replaceFirst('Exception: ', '');
      if (pesan == 'Sesi berakhir') {
        await kembaliKeLogin(context);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status pesanan gagal diperbarui: $pesan'), backgroundColor: AppTheme.warnaGalat),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<OrderModel> lima = daftarPesanan.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(AppTheme.jarakTepi),
      decoration: BoxDecoration(color: AppTheme.warnaPermukaan, borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Pesanan Menunggu Tindakan',
            style: TextStyle(fontSize: AppTheme.fontSedang, fontWeight: FontWeight.w700, color: AppTheme.warnaNavy),
          ),
          const SizedBox(height: AppTheme.radiusSedang),
          if (lima.isEmpty)
            const Text('Tidak ada pesanan yang menunggu tindakan.', style: TextStyle(fontSize: AppTheme.fontInput, color: AppTheme.warnaTeksRedup))
          else
            for (final OrderModel pesanan in lima)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.jarakTipis),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pesanan.namaProduk,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: AppTheme.fontInput, fontWeight: FontWeight.w600, color: AppTheme.warnaNavy),
                          ),
                          Text(
                            '${pesanan.namaPembeli ?? 'Pembeli'} • ${pesanan.jumlah} unit • ${pesanan.labelStatus}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _ubahStatus(context, pesanan),
                      child: Text(pesanan.status == 'paid' ? 'Siapkan' : 'Selesaikan'),
                    ),
                  ],
                ),
              ),
          if (daftarPesanan.length > 5)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onLihatSemua, child: const Text('Lihat semua')),
            ),
        ],
      ),
    );
  }
}
