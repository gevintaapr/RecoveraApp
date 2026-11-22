import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Judul bagian dalam daftar (gaya "Rekomendasi Terdekat" Recovera lama):
// ikon opsional + judul tebal, lalu badge hijau jumlah (teksKanan) atau
// tautan teks (teksTautan + onTautan) di kanan.
class JudulBagian extends StatelessWidget {
  final String judul;
  final IconData? ikon;
  final String? teksKanan;
  final String? teksTautan;
  final VoidCallback? onTautan;

  const JudulBagian({super.key, required this.judul, this.ikon, this.teksKanan, this.teksTautan, this.onTautan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.jarakTepi, bottom: AppTheme.jarakKecil),
      child: Row(
        children: [
          if (ikon != null) ...[
            Icon(ikon, size: AppTheme.ikonMata, color: AppTheme.warnaRadar),
            const SizedBox(width: AppTheme.jarakLabel),
          ],
          Expanded(
            child: Text(
              judul,
              style: const TextStyle(fontSize: AppTheme.fontJudulBagian, fontWeight: FontWeight.w800, color: AppTheme.warnaJudulKartu),
            ),
          ),
          if (teksKanan != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakKecil, vertical: AppTheme.jarakTipis),
              decoration: BoxDecoration(
                color: AppTheme.warnaLatarSukses,
                borderRadius: BorderRadius.circular(AppTheme.radiusSedang),
                border: Border.all(color: AppTheme.warnaGarisBadgeSukses),
              ),
              child: Text(
                teksKanan!,
                style: const TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w700, color: AppTheme.warnaTeksBadgeSukses),
              ),
            ),
          if (teksTautan != null && onTautan != null) TextButton(onPressed: onTautan, child: Text(teksTautan!)),
        ],
      ),
    );
  }
}
