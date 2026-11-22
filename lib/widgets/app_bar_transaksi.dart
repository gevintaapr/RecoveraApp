import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'tombol_kembali.dart';

// AppBar bergradien biru dengan kotak ikon di kiri judul (AppBar Riwayat Transaksi
// Recovera lama). Dipakai Detail pesanan; tombol back selalu tampil (TombolKembali).
class AppBarTransaksi extends StatelessWidget implements PreferredSizeWidget {
  final String judul;
  final IconData ikon;
  final bool tampilkanKembali; // false untuk tab di MainShell
  final List<Widget>? actions;

  const AppBarTransaksi({
    super.key,
    required this.judul,
    this.ikon = Icons.receipt_long_rounded,
    this.tampilkanKembali = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: tampilkanKembali ? const TombolKembali() : null,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: tampilkanKembali ? 0 : AppTheme.jarakTepi,
      actions: actions,
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.warnaUtamaGelap, AppTheme.warnaUtama, AppTheme.warnaUtamaTerang],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: AppTheme.logoLencana,
            height: AppTheme.logoLencana,
            decoration: BoxDecoration(
              color: AppTheme.warnaPutih18,
              borderRadius: BorderRadius.circular(AppTheme.radiusSedang),
            ),
            child: Icon(ikon, color: AppTheme.warnaPermukaan, size: AppTheme.ikonSedang),
          ),
          const SizedBox(width: AppTheme.radiusSedang),
          Text(
            judul,
            style: const TextStyle(fontSize: AppTheme.fontJudulTransaksi, fontWeight: FontWeight.w800, color: AppTheme.warnaPermukaan),
          ),
        ],
      ),
    );
  }
}
