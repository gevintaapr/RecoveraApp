import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Baris chip kapsul untuk menyaring status (filter Riwayat Transaksi Recovera lama):
// terpilih = biru + bayangan tipis; lainnya putih bergaris. Bisa digulir ke samping.
class ChipFilterStatus extends StatelessWidget {
  final List<String> daftarLabel;
  final int indeksAktif;
  final ValueChanged<int> onPilih;

  const ChipFilterStatus({super.key, required this.daftarLabel, required this.indeksAktif, required this.onPilih});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakTepi),
      child: Row(
        children: [
          for (int i = 0; i < daftarLabel.length; i++) ...[
            if (i > 0) const SizedBox(width: AppTheme.jarakKecil),
            _Chip(label: daftarLabel[i], terpilih: i == indeksAktif, onTap: () => onPilih(i)),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool terpilih;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.terpilih, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: terpilih,
      child: Material(
        color: terpilih ? AppTheme.warnaUtama : AppTheme.warnaPermukaan,
        elevation: terpilih ? 2 : 0,
        shadowColor: AppTheme.warnaUtama,
        shape: StadiumBorder(side: BorderSide(color: terpilih ? AppTheme.warnaUtama : AppTheme.warnaGarisCari)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppTheme.tinggiChip + AppTheme.jarakMini),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakInput),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTheme.fontInput,
                    fontWeight: terpilih ? FontWeight.w700 : FontWeight.w500,
                    color: terpilih ? AppTheme.warnaPermukaan : AppTheme.warnaTeksSedang,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
