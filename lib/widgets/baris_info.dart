import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Satu baris "label ...... nilai" di halaman detail (listing, pesanan, profil).
// Label redup di kiri, nilai tebal rata kanan; garis tipis di atas memisahkan baris.
class BarisInfo extends StatelessWidget {
  final String label;
  final String nilai;
  final Color? warnaNilai;

  const BarisInfo({super.key, required this.label, required this.nilai, this.warnaNilai});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.jarakKecil),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.warnaGaris))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: AppTheme.fontNormal, color: AppTheme.warnaTeksRedup)),
          ),
          const SizedBox(width: AppTheme.jarakKecil),
          Expanded(
            flex: 3,
            child: Text(
              nilai,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: AppTheme.fontNormal,
                fontWeight: FontWeight.w600,
                color: warnaNilai ?? AppTheme.warnaTeks,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
