import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Bar aksi cepat di Dasbor penjual (_buildQuickActionsBar Recovera lama, tanpa ESG):
// kotak putih kecil berikon biru: Upload Stok, Inventaris, Pesanan.
class BarAksiCepat extends StatelessWidget {
  final VoidCallback onUploadStok;
  final VoidCallback onBukaStok;
  final VoidCallback onBukaPesanan;

  const BarAksiCepat({super.key, required this.onUploadStok, required this.onBukaStok, required this.onBukaPesanan});

  @override
  Widget build(BuildContext context) {
    final List<(IconData, String, VoidCallback)> daftarAksi = [
      (Icons.add_a_photo_outlined, 'Upload Stok', onUploadStok),
      (Icons.inventory_2_outlined, 'Inventaris', onBukaStok),
      (Icons.receipt_long_outlined, 'Pesanan', onBukaPesanan),
    ];
    return Row(
      children: [
        for (final (IconData, String, VoidCallback) aksi in daftarAksi)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakTipis),
              child: Material(
                color: AppTheme.warnaPermukaan,
                borderRadius: BorderRadius.circular(AppTheme.radiusTombol),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusTombol),
                  onTap: aksi.$3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.jarakSedang, horizontal: AppTheme.jarakMini),
                    child: Column(
                      children: [
                        Icon(aksi.$1, color: AppTheme.warnaUtama, size: AppTheme.ikonSedang),
                        const SizedBox(height: AppTheme.jarakMini),
                        Text(
                          aksi.$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w600, color: AppTheme.warnaNavy),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
