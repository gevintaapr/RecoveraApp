import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Label status (pesanan dan listing): latar lembut + teks tebal.
// Status selalu tertulis sebagai teks, warna hanya penguat.
class StatusBadge extends StatelessWidget {
  final String status; // pesanan: paid/in_progress/completed; listing: draft/review/active/sold/expired
  final String label; // teks yang tampil, mis. "Siap diambil"

  const StatusBadge({super.key, required this.status, required this.label});

  // [latar, teks]; semua pasangan lolos kontras 4.5:1.
  List<Color> get _pasanganWarna {
    switch (status) {
      case 'active':
      case 'completed':
        return const [AppTheme.warnaLatarSukses, AppTheme.warnaSukses];
      case 'paid':
      case 'draft':
      case 'review':
        return const [AppTheme.warnaLatarPeringatan, AppTheme.warnaTeksPeringatan];
      case 'in_progress':
        return const [AppTheme.warnaLatarInfo, AppTheme.warnaTeksInfo];
      case 'expired':
        return const [AppTheme.warnaLatarBahaya, AppTheme.warnaTeksPeringatan];
      default:
        return const [AppTheme.warnaLatarNetral, AppTheme.warnaTeksSedang];
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> warna = _pasanganWarna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakKecil, vertical: AppTheme.jarakMini / 2),
      decoration: BoxDecoration(
        color: warna[0],
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: warna[1], fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w800),
      ),
    );
  }
}
