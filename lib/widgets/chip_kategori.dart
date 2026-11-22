import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Chip kategori berikon di bawah kolom cari Katalog.
// Terpilih: latar biru + ikon centang; tidak terpilih: putih bergaris + ikon kategori.
// Chip terlihat setinggi 32, tapi area ketuknya 44 (padding vertikal).
class ChipKategori extends StatelessWidget {
  final String label;
  final IconData ikon;
  final bool terpilih;
  final VoidCallback onTap;

  const ChipKategori({
    super.key,
    required this.label,
    required this.ikon,
    required this.terpilih,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color warnaIsi = terpilih ? AppTheme.warnaPermukaan : AppTheme.warnaTeksSedang;

    return Semantics(
      button: true,
      selected: terpilih,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: (AppTheme.ukuranTombolIkon - AppTheme.tinggiChip) / 2,
          ),
          child: Container(
            height: AppTheme.tinggiChip,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
            decoration: BoxDecoration(
              color: terpilih ? AppTheme.warnaUtama : AppTheme.warnaPermukaan,
              borderRadius: BorderRadius.circular(AppTheme.radiusChip),
              border: Border.all(color: terpilih ? AppTheme.warnaUtama : AppTheme.warnaGarisTegas),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(terpilih ? Icons.check : ikon, size: AppTheme.fontSedang, color: warnaIsi),
                const SizedBox(width: AppTheme.jarakMini),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTheme.fontNormal,
                    fontWeight: terpilih ? FontWeight.w700 : FontWeight.w600,
                    color: warnaIsi,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
