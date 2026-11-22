import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Kartu putih satu bagian di halaman detail (mis. "Lelang Belanda", "Spesifikasi"):
// judul opsional di kiri, widget kecil opsional di kanan (chip), lalu isinya.
class KartuBagian extends StatelessWidget {
  final String? judul;
  final Widget? kanan;
  final List<Widget> children;

  const KartuBagian({super.key, this.judul, this.kanan, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.jarakSedang),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (judul != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      judul!,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSedang,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.warnaNavy,
                      ),
                    ),
                  ),
                  ?kanan,
                ],
              ),
              const SizedBox(height: AppTheme.jarakKecil),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}
