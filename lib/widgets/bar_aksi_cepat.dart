import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Bar aksi cepat untuk Dasbor Penjual (T5):
// - Upload Stok (ke UploadInvoiceScreen)
// - Inventaris Stok (pindah tab ke Stok)
// - Kelola Pesanan (ke Semua Pesanan Masuk)
class BarAksiCepat extends StatelessWidget {
  final VoidCallback onUploadStok;
  final VoidCallback onBukaStok;
  final VoidCallback onBukaPesanan;

  const BarAksiCepat({
    super.key,
    required this.onUploadStok,
    required this.onBukaStok,
    required this.onBukaPesanan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.jarakKecil,
        vertical: AppTheme.jarakKecil,
      ),
      decoration: BoxDecoration(
        color: AppTheme.warnaPermukaan,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.warnaGaris),
      ),
      child: Row(
        children: [
          Expanded(
            child: _itemAksi(
              ikon: Icons.add_photo_alternate_outlined,
              label: 'Upload Stok',
              warnaIkon: AppTheme.warnaUtama,
              onTap: onUploadStok,
            ),
          ),
          Container(height: 36, width: 1, color: AppTheme.warnaGaris),
          Expanded(
            child: _itemAksi(
              ikon: Icons.inventory_2_outlined,
              label: 'Inventaris',
              warnaIkon: AppTheme.warnaUtama,
              onTap: onBukaStok,
            ),
          ),
          Container(height: 36, width: 1, color: AppTheme.warnaGaris),
          Expanded(
            child: _itemAksi(
              ikon: Icons.receipt_long_outlined,
              label: 'Pesanan',
              warnaIkon: AppTheme.warnaUtama,
              onTap: onBukaPesanan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemAksi({
    required IconData ikon,
    required String label,
    required Color warnaIkon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, color: warnaIkon, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontKecil,
                fontWeight: FontWeight.w600,
                color: AppTheme.warnaTeks,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

