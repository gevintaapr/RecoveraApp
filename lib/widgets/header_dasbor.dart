import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/notifikasi_controller.dart';
import '../models/user_model.dart';
import '../screens/shared/notification_screen.dart';
import '../theme/app_theme.dart';
import 'header_gelombang.dart';
import 'merek_recovera.dart';
import 'tombol_ikon_kaca.dart';

// Header gelombang Dasbor penjual (_buildFixedWaveHeader Recovera lama):
// kolom kiri = merek + label PENJUAL, sapaan perusahaan, kapsul kota gudang;
// kanan = tombol lonceng (badge belum dibaca, GetX).
class HeaderDasbor extends StatelessWidget {
  final UserModel profil;

  const HeaderDasbor({super.key, required this.profil});

  @override
  Widget build(BuildContext context) {
    final NotifikasiController notifikasiController = Get.find<NotifikasiController>();
    final String namaUsaha = profil.namaPerusahaan?.isNotEmpty == true ? profil.namaPerusahaan! : profil.nama;
    final String kotaGudang = profil.kota?.isNotEmpty == true ? profil.kota! : '-';

    return HeaderGelombang(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const MerekRecovera(label: 'PENJUAL'),
                const SizedBox(height: AppTheme.jarakMini),
                Text(
                  'Halo, $namaUsaha',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSubjudul,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.warnaPermukaan,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: AppTheme.jarakLabel),
                // Kapsul info (bukan tombol): kota gudang dari profil.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.radiusSedang, vertical: AppTheme.jarakLabel),
                  decoration: ShapeDecoration(
                    color: AppTheme.warnaPutih18,
                    shape: const StadiumBorder(side: BorderSide(color: AppTheme.warnaPutih30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warehouse_rounded, size: AppTheme.ikonPanah, color: AppTheme.warnaAksenMuda),
                      const SizedBox(width: AppTheme.jarakMini),
                      Flexible(
                        child: Text(
                          'Gudang $kotaGudang',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w600, color: AppTheme.warnaPermukaan),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.jarakSedang),
          Obx(() => TombolIkonKaca(
                ikon: Icons.notifications_none_rounded,
                keterangan: 'Notifikasi',
                jumlahBadge: notifikasiController.jumlahBelumDibaca.value,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                ),
              )),
        ],
      ),
    );
  }
}
