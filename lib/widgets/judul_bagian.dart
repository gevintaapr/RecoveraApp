import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'chip_lembut.dart';

// Judul bagian dalam daftar (mis. "Lelang terdekat", "Perlu disiapkan"), dengan
// chip jumlah di kanan (teksKanan) atau tautan teks (teksTautan + onTautan).
class JudulBagian extends StatelessWidget {
  final String judul;
  final String? teksKanan;
  final String? teksTautan;
  final VoidCallback? onTautan;

  const JudulBagian({super.key, required this.judul, this.teksKanan, this.teksTautan, this.onTautan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.jarakKecil),
      child: Row(
        children: [
          Expanded(
            child: Text(
              judul,
              style: const TextStyle(
                fontSize: AppTheme.fontSubjudul,
                fontWeight: FontWeight.w800,
                color: AppTheme.warnaNavy,
              ),
            ),
          ),
          if (teksKanan != null)
            ChipLembut(teks: teksKanan!, warnaLatar: AppTheme.warnaLatarSukses, warnaTeks: AppTheme.warnaSukses),
          if (teksTautan != null && onTautan != null)
            TextButton(onPressed: onTautan, child: Text(teksTautan!)),
        ],
      ),
    );
  }
}
