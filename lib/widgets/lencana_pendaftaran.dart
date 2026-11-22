import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Isi header biru Register (_OfficialBadge Recovera lama):
// logo + "Recovera", lalu kapsul "Pendaftaran Mitra Resmi Recovera".
class LencanaPendaftaran extends StatelessWidget {
  const LencanaPendaftaran({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/recovera-logo-mark.png',
              width: AppTheme.logoLencana,
              height: AppTheme.logoLencana,
              semanticLabel: 'Logo Recovera',
            ),
            const SizedBox(width: AppTheme.jarakKecil),
            const Text(
              'Recovera',
              style: TextStyle(
                fontSize: AppTheme.fontJudulLencana,
                fontWeight: FontWeight.w800,
                color: AppTheme.warnaPermukaan,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.jarakKecil),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang, vertical: AppTheme.jarakMini),
          decoration: BoxDecoration(
            color: AppTheme.warnaKaca,
            borderRadius: BorderRadius.circular(AppTheme.radiusKapsul),
            border: Border.all(color: AppTheme.warnaGarisKaca),
          ),
          child: const Text(
            'Pendaftaran Mitra Resmi Recovera',
            style: TextStyle(
              fontSize: AppTheme.fontLabel,
              fontWeight: FontWeight.w600,
              color: AppTheme.warnaPermukaan,
            ),
          ),
        ),
      ],
    );
  }
}
