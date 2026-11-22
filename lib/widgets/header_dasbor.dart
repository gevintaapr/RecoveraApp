import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/notifikasi_controller.dart';
import '../models/user_model.dart';
import '../screens/shared/notification_screen.dart';
import '../theme/app_theme.dart';
import 'header_gelombang.dart';
import 'merek_recovera.dart';
import 'tombol_ikon_kaca.dart';

// Header gelombang: nama aplikasi + lonceng kaca (badge GetX), sapaan perusahaan, kota gudang.
class HeaderDasbor extends StatelessWidget {
  final UserModel profil;

  const HeaderDasbor({super.key, required this.profil});

  @override
  Widget build(BuildContext context) {
    final NotifikasiController notifikasiController =
        Get.find<NotifikasiController>();
    final String namaUsaha = profil.namaPerusahaan?.isNotEmpty == true
        ? profil.namaPerusahaan!
        : profil.nama;
    final String kotaGudang = profil.kota?.isNotEmpty == true
        ? profil.kota!
        : '-';

    return HeaderGelombang(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: MerekRecovera(label: 'PENJUAL')),
              Obx(
                () => TombolIkonKaca(
                  ikon: Icons.notifications_none,
                  keterangan: 'Notifikasi',
                  jumlahBadge: notifikasiController.jumlahBelumDibaca.value,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.jarakMini),
          Text(
            'Halo, $namaUsaha',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppTheme.fontSubjudul,
              fontWeight: FontWeight.w700,
              color: AppTheme.warnaPermukaan,
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.warehouse_outlined,
                size: AppTheme.ikonKecil,
                color: AppTheme.warnaPermukaan,
              ),
              const SizedBox(width: AppTheme.jarakMini),
              Text(
                'Gudang $kotaGudang',
                style: const TextStyle(
                  fontSize: AppTheme.fontKecil,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.warnaPermukaan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
