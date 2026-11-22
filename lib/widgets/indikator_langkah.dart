import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Widget Indikator Langkah Upload Stok Penjual (T7):
// Langkah 1: Faktur -> Langkah 2: Data Produk -> Langkah 3: Harga & Terbit
class IndikatorLangkah extends StatelessWidget {
  final int langkahAktif; // 1, 2, atau 3

  const IndikatorLangkah({super.key, required this.langkahAktif});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.jarakSedang,
        vertical: AppTheme.jarakKecil,
      ),
      margin: const EdgeInsets.only(bottom: AppTheme.jarakSedang),
      decoration: BoxDecoration(
        color: AppTheme.warnaPermukaan,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.warnaGaris),
      ),
      child: Row(
        children: [
          _buildItemLangkah(nomor: 1, label: 'Faktur', aktif: langkahAktif >= 1, selesai: langkahAktif > 1),
          _buildGarisPenghubung(aktif: langkahAktif > 1),
          _buildItemLangkah(nomor: 2, label: 'Data Produk', aktif: langkahAktif >= 2, selesai: langkahAktif > 2),
          _buildGarisPenghubung(aktif: langkahAktif > 2),
          _buildItemLangkah(nomor: 3, label: 'Harga & Terbit', aktif: langkahAktif >= 3, selesai: false),
        ],
      ),
    );
  }

  Widget _buildItemLangkah({
    required int nomor,
    required String label,
    required bool aktif,
    required bool selesai,
  }) {
    final Color warnaLingkaran = aktif ? AppTheme.warnaUtama : AppTheme.warnaGaris;
    final Color warnaTeks = aktif ? AppTheme.warnaUtama : AppTheme.warnaTeksRedup;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selesai ? AppTheme.warnaUtama : (aktif ? AppTheme.warnaUtama.withValues(alpha: 0.15) : AppTheme.warnaLatar),
            border: Border.all(color: warnaLingkaran, width: 2),
          ),
          child: Center(
            child: selesai
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$nomor',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: aktif ? AppTheme.warnaUtama : AppTheme.warnaTeksRedup,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
            color: warnaTeks,
          ),
        ),
      ],
    );
  }

  Widget _buildGarisPenghubung({required bool aktif}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
        color: aktif ? AppTheme.warnaUtama : AppTheme.warnaGaris,
      ),
    );
  }
}

