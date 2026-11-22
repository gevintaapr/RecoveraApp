import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Tombol bulat putih transparan untuk di atas header biru (HeaderIconButton lama).
class TombolIkonHeader extends StatelessWidget {
  final IconData ikon;
  final String keterangan;
  final VoidCallback onTap;

  const TombolIkonHeader({super.key, required this.ikon, required this.keterangan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: keterangan,
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: AppTheme.ukuranTombolIkon, minHeight: AppTheme.ukuranTombolIkon),
      icon: Container(
        width: AppTheme.tombolHeader,
        height: AppTheme.tombolHeader,
        decoration: const BoxDecoration(color: AppTheme.warnaKaca, shape: BoxShape.circle),
        child: Icon(ikon, color: AppTheme.warnaPermukaan, size: AppTheme.ikonSedang),
      ),
    );
  }
}
