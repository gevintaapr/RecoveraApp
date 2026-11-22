import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Header biru layar Login & Register (AuthHeader Recovera lama):
// baris tombol kiri/kanan di atas, konten (logo) di tengah.
// Tinggi = 29% layar, dibatasi 170..260.
class HeaderAuth extends StatelessWidget {
  final Widget? tombolKiri;
  final Widget? tombolKanan;
  final Widget? child;

  const HeaderAuth({super.key, this.tombolKiri, this.tombolKanan, this.child});

  @override
  Widget build(BuildContext context) {
    // Lebih pendek dari versi lama (29%) supaya ruang kosong biru tidak terlalu besar.
    final double tinggi = (MediaQuery.sizeOf(context).height * 0.22).clamp(150.0, 200.0);
    final bool adaTombol = tombolKiri != null || tombolKanan != null;

    return Container(
      height: tinggi,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.warnaUtama, AppTheme.warnaUtamaTerang],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakBesar),
          child: Column(
            children: [
              // Baris tombol hanya dibuat bila ada tombol (Login tidak punya).
              if (adaTombol)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    tombolKiri ?? const SizedBox(width: AppTheme.ukuranTombolIkon),
                    tombolKanan ?? const SizedBox(width: AppTheme.ukuranTombolIkon),
                  ],
                ),
              if (child != null)
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(bottom: AppTheme.jarakSedang),
                    child: FittedBox(fit: BoxFit.scaleDown, child: child!),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
