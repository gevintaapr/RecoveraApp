import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorit_controller.dart';
import '../models/favorit_model.dart';
import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'dialog_memuat.dart';

// Tombol "Ingatkan saya" (Modul VII, scheduled notification).
// Menjadwalkan pop-up 30 menit sebelum lelang berakhir. Karena dijadwalkan
// oleh Android, pengingat tetap muncul walau aplikasi sudah ditutup.
//
// Dipakai di dua tempat:
// - detail listing (bentukIkon = false) -> OutlinedButton
// - kartu di halaman Favorit (bentukIkon = true) -> ikon lonceng
// Status aktif/tidak disimpan di Hive lewat FavoritController (GetX), dan tombol
// dibungkus Obx, jadi lonceng di kedua halaman selalu sama tanpa setState.
class TombolIngatkan extends StatelessWidget {
  final FavoritModel favorit;
  final bool bentukIkon;

  const TombolIngatkan({super.key, required this.favorit, this.bentukIkon = false});

  // Dialog loading -> FavoritController.aturPengingat -> tutup dialog -> SnackBar.
  Future<void> _pasangAtauBatalkan(BuildContext context, FavoritController favoritController) async {
    final bool sedangAktif = favoritController.pengingatTerjadwal(favorit.idListing);
    tampilkanDialogMemuat(
      context,
      pesan: sedangAktif ? 'Membatalkan pengingat...' : 'Memasang pengingat...',
    );
    try {
      final bool sekarangAktif = await favoritController.aturPengingat(favorit);
      if (!context.mounted) return;
      Navigator.pop(context); // tutup dialog loading
      _tampilkanPesan(
        context,
        sekarangAktif
            ? 'Pengingat dipasang pukul ${ListingModel.formatJam(favorit.waktuPengingat)} '
                '(produk tersimpan di Favorit)'
            : 'Pengingat dibatalkan',
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // tutup dialog loading
      _tampilkanPesan(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _tampilkanPesan(BuildContext context, String pesan) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  @override
  Widget build(BuildContext context) {
    final FavoritController favoritController = Get.find<FavoritController>();

    return Obx(() {
      final bool aktif = favoritController.pengingatTerjadwal(favorit.idListing);
      if (bentukIkon) {
        return IconButton(
          tooltip: aktif ? 'Batalkan pengingat' : 'Ingatkan saya',
          icon: Icon(aktif ? Icons.notifications_active : Icons.notifications_none_outlined),
          color: AppTheme.warnaAksen,
          onPressed: () => _pasangAtauBatalkan(context, favoritController),
        );
      }
      return OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppTheme.tinggiInput),
          backgroundColor: aktif ? AppTheme.warnaLatarInfo : AppTheme.warnaPermukaan,
          foregroundColor: aktif ? AppTheme.warnaTeksInfo : AppTheme.warnaUtama,
        ),
        onPressed: () => _pasangAtauBatalkan(context, favoritController),
        icon: Icon(aktif ? Icons.notifications_active : Icons.notifications_none, size: AppTheme.ikonKecil),
        label: Text(aktif ? 'Pengingat aktif, ketuk untuk batal' : 'Ingatkan 30 menit sebelum berakhir'),
      );
    });
  }
}
