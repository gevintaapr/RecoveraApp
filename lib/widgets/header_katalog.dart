import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorit_controller.dart';
import '../controllers/notifikasi_controller.dart';
import '../routes/app_routes.dart';
import '../screens/shared/notification_screen.dart';
import '../theme/app_theme.dart';
import 'header_gelombang.dart';
import 'merek_recovera.dart';
import 'tombol_ikon_kaca.dart';

// Header gelombang di atas Katalog pembeli:
// - baris atas: nama Recovera + tombol kaca Favorit (badge jumlah, GetX) dan
//   Notifikasi (badge belum dibaca, GetX)
// - sapaan "Halo, {nama}"
// - kapsul lokasi: kota dari GPS + radius filter; ketuk -> buka sheet filter
class HeaderKatalog extends StatelessWidget {
  final String namaPengguna;
  final bool adaLokasi;
  final String? pesanLokasi;
  final String? namaKota;
  final double? radiusKm;
  final VoidCallback onBukaFilter;

  const HeaderKatalog({
    super.key,
    required this.namaPengguna,
    required this.adaLokasi,
    required this.pesanLokasi,
    required this.namaKota,
    required this.radiusKm,
    required this.onBukaFilter,
  });

  String get _teksLokasi {
    if (!adaLokasi) return pesanLokasi ?? 'Mendeteksi lokasi...';
    if (namaKota == null || namaKota!.isEmpty) return 'Mendeteksi nama kota...';
    return namaKota!;
  }

  @override
  Widget build(BuildContext context) {
    final FavoritController favoritController = Get.find<FavoritController>();
    final NotifikasiController notifikasiController = Get.find<NotifikasiController>();

    return HeaderGelombang(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: MerekRecovera()),
              Obx(() => TombolIkonKaca(
                    ikon: Icons.favorite_border,
                    keterangan: 'Favorit',
                    jumlahBadge: favoritController.jumlahFavorit,
                    onPressed: () => Get.toNamed(AppRoutes.favorit),
                  )),
              const SizedBox(width: AppTheme.jarakKecil),
              Obx(() => TombolIkonKaca(
                    ikon: Icons.notifications_none,
                    keterangan: 'Notifikasi',
                    jumlahBadge: notifikasiController.jumlahBelumDibaca.value,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: AppTheme.jarakMini),
          Text(
            'Halo, ${namaPengguna.isNotEmpty ? namaPengguna : 'Pelaku Usaha'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppTheme.fontSubjudul,
              fontWeight: FontWeight.w700,
              color: AppTheme.warnaPermukaan,
            ),
          ),
          const SizedBox(height: AppTheme.jarakKecil),
          _KapsulLokasi(teks: _teksLokasi, radiusKm: radiusKm, onTap: onBukaFilter),
        ],
      ),
    );
  }
}

class _KapsulLokasi extends StatelessWidget {
  final String teks;
  final double? radiusKm;
  final VoidCallback onTap;

  const _KapsulLokasi({required this.teks, required this.radiusKm, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.warnaKaca,
      shape: const StadiumBorder(side: BorderSide(color: AppTheme.warnaGarisKaca)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppTheme.ukuranTombolIkon - AppTheme.jarakKecil),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_outlined, size: AppTheme.ikonKecil, color: AppTheme.warnaPermukaan),
                const SizedBox(width: AppTheme.jarakMini),
                Flexible(
                  child: Text(
                    teks,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppTheme.fontKecil,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warnaPermukaan,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.jarakMini),
                Text(
                  radiusKm == null ? '· Semua jarak' : '· Radius ${radiusKm!.round()} km',
                  style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaPermukaan),
                ),
                const Icon(Icons.expand_more, size: AppTheme.ikonKecil, color: AppTheme.warnaPermukaan),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
