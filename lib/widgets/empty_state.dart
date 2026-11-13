import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Tampilan saat data kosong atau gagal dimuat.
// teksTombol + onTombolDitekan opsional (mis. tombol "Coba lagi").
class EmptyState extends StatelessWidget {
  final IconData ikon;
  final String pesan;
  final String? teksTombol;
  final VoidCallback? onTombolDitekan;

  const EmptyState({
    super.key,
    required this.ikon,
    required this.pesan,
    this.teksTombol,
    this.onTombolDitekan,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.jarakBesar),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: AppTheme.ikonLogo, color: AppTheme.warnaTeksRedup),
            const SizedBox(height: AppTheme.jarakSedang),
            Text(pesan, style: AppTheme.gayaTeksRedup, textAlign: TextAlign.center),
            if (teksTombol != null && onTombolDitekan != null) ...[
              const SizedBox(height: AppTheme.jarakSedang),
              OutlinedButton(onPressed: onTombolDitekan, child: Text(teksTombol!)),
            ],
          ],
        ),
      ),
    );
  }
}
