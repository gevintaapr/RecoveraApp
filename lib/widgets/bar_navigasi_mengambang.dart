import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Pembungkus BottomNavigationBar agar tampil mengambang: kartu putih membulat
// dengan jarak dari tepi layar dan bayangan lembut. Gaya item mengikuti
// bottom nav Recovera lama (item aktif berlatar pil biru muda).
// BottomNavigationBar-nya tetap ditulis di MainShell (bukti Modul IV).
// Pasangkan dengan Scaffold(extendBody: true) agar isi layar terlihat di sela bar.
class BarNavigasiMengambang extends StatelessWidget {
  final BottomNavigationBar child;

  const BarNavigasiMengambang({super.key, required this.child});

  // Ikon tab aktif dibungkus pil biru muda, seperti _NavItem Recovera lama.
  static Widget ikonAktif(IconData ikon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakTepi, vertical: AppTheme.jarakMini),
      decoration: BoxDecoration(
        color: AppTheme.warnaLatarAktif,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Icon(ikon, size: AppTheme.ikonNav),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppTheme.jarakSedang),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakTepi),
        child: DecoratedBox(
          // Bayangan di luar kartu: menandai bar berada di atas isi layar.
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusNav),
            boxShadow: const [
              BoxShadow(color: AppTheme.warnaBayanganNav, blurRadius: 24, offset: Offset(0, 8)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusNav),
            child: Theme(
              data: Theme.of(context).copyWith(
                // Tanpa efek riak abu-abu saat diketuk, seperti nav lama.
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: AppTheme.warnaPermukaan,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppTheme.warnaUtama,
                  unselectedItemColor: AppTheme.warnaTeksRedup,
                  selectedLabelStyle: TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w600),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
