import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Satu baris menu di halaman Profil (_ProfileMenuItem Recovera lama):
// ikon dalam lingkaran berwarna, label tebal, subjudul berwarna, panah di kanan.
// onTap null = baris informasi saja (tanpa panah, tidak bisa diketuk).
class MenuProfil extends StatelessWidget {
  final IconData ikon;
  final Color latarIkon;
  final Color warnaIkon;
  final String label;
  final String? subjudul;
  final Color? warnaSubjudul;
  final VoidCallback? onTap;

  const MenuProfil({
    super.key,
    required this.ikon,
    required this.latarIkon,
    required this.warnaIkon,
    required this.label,
    this.subjudul,
    this.warnaSubjudul,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.jarakLabel),
      child: Material(
        color: AppTheme.warnaPermukaan,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.jarakInput,
              vertical: AppTheme.jarakSedang,
            ),
            child: Row(
              children: [
                Container(
                  width: AppTheme.tombolHeader,
                  height: AppTheme.tombolHeader,
                  decoration: BoxDecoration(
                    color: latarIkon,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(ikon, size: AppTheme.ikonMata, color: warnaIkon),
                ),
                const SizedBox(width: AppTheme.jarakInput),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: AppTheme.fontNormal,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.warnaJudulMenu,
                        ),
                      ),
                      if (subjudul != null)
                        Text(
                          subjudul!,
                          style: TextStyle(
                            fontSize: AppTheme.fontLabel,
                            fontWeight: FontWeight.w500,
                            color: warnaSubjudul ?? AppTheme.warnaTeksRedup,
                          ),
                        ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: AppTheme.ikonCentang,
                    color: AppTheme.warnaTeksRedup,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
