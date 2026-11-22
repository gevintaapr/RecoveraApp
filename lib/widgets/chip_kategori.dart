import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Chip kategori berikon di Beranda (ChoiceChip Recovera lama):
// terpilih = biru penuh + teks putih; tidak terpilih = putih bergaris.
// Area ketuk setinggi 44 lewat padding vertikal.
class ChipKategori extends StatelessWidget {
  final String label;
  final IconData? ikon;
  final bool terpilih;
  final VoidCallback onTap;

  const ChipKategori({super.key, required this.label, this.ikon, required this.terpilih, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color warnaIsi = terpilih ? AppTheme.warnaPermukaan : AppTheme.warnaTeksSedang;
    return Semantics(
      button: true,
      selected: terpilih,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSedang),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: (AppTheme.ukuranTombolIkon - AppTheme.tinggiChip) / 2),
          child: Container(
            height: AppTheme.tinggiChip,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
            decoration: BoxDecoration(
              color: terpilih ? AppTheme.warnaUtama : AppTheme.warnaPermukaan,
              borderRadius: BorderRadius.circular(AppTheme.radiusSedang),
              border: Border.all(color: terpilih ? AppTheme.warnaUtama : AppTheme.warnaGarisCari),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ikon != null) ...[
                  Icon(ikon, size: AppTheme.fontNormal, color: warnaIsi),
                  const SizedBox(width: AppTheme.jarakMini),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTheme.fontKecil,
                    fontWeight: terpilih ? FontWeight.w700 : FontWeight.w500,
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
