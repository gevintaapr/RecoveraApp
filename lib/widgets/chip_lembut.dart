import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Label kecil berlatar lembut (mis. "12 produk", "-65%", "Stok 46 karton").
// Bukan tombol; hanya informasi. Pasangan warna latar/teks dipilih dari app_theme
// yang sudah lolos kontras.
class ChipLembut extends StatelessWidget {
  final String teks;
  final Color warnaLatar;
  final Color warnaTeks;

  const ChipLembut({
    super.key,
    required this.teks,
    this.warnaLatar = AppTheme.warnaLatarNetral,
    this.warnaTeks = AppTheme.warnaTeksSedang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakKecil, vertical: AppTheme.jarakMini / 2),
      decoration: BoxDecoration(
        color: warnaLatar,
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
      ),
      child: Text(
        teks,
        maxLines: 1,
        style: TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w700, color: warnaTeks),
      ),
    );
  }
}
