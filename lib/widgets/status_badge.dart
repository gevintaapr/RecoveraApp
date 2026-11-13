import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Label status pesanan berwarna. Warna diambil dari app_theme.
class StatusBadge extends StatelessWidget {
  final String status; // paid / in_progress / completed (dari server)
  final String label; // teks yang tampil, mis. "Siap diambil"

  const StatusBadge({super.key, required this.status, required this.label});

  Color get _warna {
    switch (status) {
      case 'paid':
        return AppTheme.warnaAksen;
      case 'in_progress':
        return AppTheme.warnaUtama;
      default:
        return AppTheme.warnaTeksRedup;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.jarakKecil,
        vertical: AppTheme.jarakKecil / 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: _warna),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Text(
        label,
        style: TextStyle(color: _warna, fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w600),
      ),
    );
  }
}
