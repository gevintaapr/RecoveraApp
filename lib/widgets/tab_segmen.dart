import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Tab segmen (mis. Aktif / Draft / Terjual / Habis di Stok penjual).
// Segmen terpilih berlatar putih di atas wadah abu muda.
class TabSegmen extends StatelessWidget {
  final List<String> daftarLabel;
  final int indeksAktif;
  final ValueChanged<int> onPilih;

  const TabSegmen({
    super.key,
    required this.daftarLabel,
    required this.indeksAktif,
    required this.onPilih,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.ukuranTombolIkon,
      padding: const EdgeInsets.all(AppTheme.jarakMini / 2),
      decoration: BoxDecoration(
        color: AppTheme.warnaLatarNetral,
        borderRadius: BorderRadius.circular(AppTheme.radiusTombol),
      ),
      child: Row(
        children: List.generate(daftarLabel.length, (indeks) {
          final bool aktif = indeks == indeksAktif;
          return Expanded(
            child: Semantics(
              button: true,
              selected: aktif,
              child: Material(
                color: aktif ? AppTheme.warnaPermukaan : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                  onTap: () => onPilih(indeks),
                  child: Center(
                    child: Text(
                      daftarLabel[indeks],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTheme.fontKecil,
                        fontWeight: aktif ? FontWeight.w800 : FontWeight.w600,
                        color: aktif ? AppTheme.warnaNavy : AppTheme.warnaTeksSedang,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
