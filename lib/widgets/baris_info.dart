import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Satu baris "label : nilai" di halaman detail (listing dan pesanan).
class BarisInfo extends StatelessWidget {
  final String label;
  final String nilai;

  const BarisInfo({super.key, required this.label, required this.nilai});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.jarakKecil / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: AppTheme.gayaTeksRedup)),
          Expanded(flex: 3, child: Text(nilai)),
        ],
      ),
    );
  }
}
