import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Logo + tulisan "Recovera" tebal di header biru (sama seperti header Recovera lama),
// dengan label kecil peran (mis. "RECOVERA B2B" / "PENJUAL").
class MerekRecovera extends StatelessWidget {
  final String label;

  const MerekRecovera({super.key, this.label = 'RECOVERA B2B'});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Image.asset(
            'assets/images/recovera-logo-mark.png',
            width: AppTheme.logoHeader,
            height: AppTheme.logoHeader,
            semanticLabel: 'Logo Recovera',
          ),
          const SizedBox(width: AppTheme.jarakKecil),
          const Text(
            'Recovera',
            style: TextStyle(
              fontSize: AppTheme.fontBesar,
              fontWeight: FontWeight.w900,
              color: AppTheme.warnaPermukaan,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(width: AppTheme.jarakKecil),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakLabel, vertical: AppTheme.jarakTipis),
            decoration: BoxDecoration(
              color: AppTheme.warnaKaca,
              borderRadius: BorderRadius.circular(AppTheme.jarakLabel),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontMini,
                fontWeight: FontWeight.w800,
                color: AppTheme.warnaPermukaan,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
