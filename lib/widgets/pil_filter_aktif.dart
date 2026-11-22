import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'filter_sheet.dart';

// Baris pil filter aktif yang bisa dihapus satu per satu (T2).
class BarisPilFilterAktif extends StatelessWidget {
  final FilterKatalog filter;
  final ValueChanged<FilterKatalog> onFilterDiubah;

  const BarisPilFilterAktif({
    super.key,
    required this.filter,
    required this.onFilterDiubah,
  });

  @override
  Widget build(BuildContext context) {
    if (filter.jumlahFilterAktif == 0) return const SizedBox.shrink();

    final List<Widget> pil = [];

    // Pil Radius
    if (filter.radiusKm != null) {
      pil.add(_buatPil(
        label: 'Jarak ≤ ${filter.radiusKm!.toInt()} km',
        icon: Icons.radar_rounded,
        onHapus: () => onFilterDiubah(filter.copyWith(radiusKm: () => null)),
      ));
    }

    // Pil Sisa Hari
    if (filter.maksSisaHari != null) {
      pil.add(_buatPil(
        label: 'Exp ≤ ${filter.maksSisaHari} Hari',
        icon: Icons.hourglass_bottom_rounded,
        onHapus: () => onFilterDiubah(filter.copyWith(maksSisaHari: () => null)),
      ));
    }

    // Pil Urutan
    if (filter.urutan != 'nearest') {
      String labelUrutan = 'Urutan: ';
      switch (filter.urutan) {
        case 'cheapest':
          labelUrutan += 'Termurah';
          break;
        case 'expiring_soon':
          labelUrutan += 'Segera Exp';
          break;
        case 'discount':
          labelUrutan += 'Diskon Tertinggi';
          break;
      }
      pil.add(_buatPil(
        label: labelUrutan,
        icon: Icons.swap_vert_rounded,
        onHapus: () => onFilterDiubah(filter.copyWith(urutan: 'nearest')),
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
      child: Row(children: pil),
    );
  }

  Widget _buatPil({
    required String label,
    required IconData icon,
    required VoidCallback onHapus,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: AppTheme.jarakKecil, bottom: AppTheme.jarakKecil),
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
      decoration: BoxDecoration(
        color: AppTheme.warnaUtama.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.warnaUtama.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.warnaUtama),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTheme.fontKecil,
              fontWeight: FontWeight.w600,
              color: AppTheme.warnaUtama,
            ),
          ),
          const SizedBox(width: 2),
          InkWell(
            onTap: onHapus,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close_rounded, size: 14, color: AppTheme.warnaUtama),
            ),
          ),
        ],
      ),
    );
  }
}

