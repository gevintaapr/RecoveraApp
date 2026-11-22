import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'indikator_langkah.dart';

// AppBar putih untuk alur upload stok penjual: judul "Upload stok" di tengah
// dan stepper 4 langkah (Faktur, Data, Harga, Terbit) di bawahnya.
class AppBarUpload extends StatelessWidget implements PreferredSizeWidget {
  final int langkahAktif;

  const AppBarUpload({super.key, required this.langkahAktif});

  // Tinggi toolbar + tinggi stepper (lingkaran + label + jarak).
  static const double _tinggiStepper =
      AppTheme.ukuranLingkaranLangkah + AppTheme.fontLabel + AppTheme.jarakBesar * 2;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + _tinggiStepper);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Latar putih (karena ada stepper), jadi ikon & judul dibuat navy agar back terlihat.
      backgroundColor: AppTheme.warnaPermukaan,
      foregroundColor: AppTheme.warnaNavy,
      titleTextStyle: const TextStyle(
        fontSize: AppTheme.fontSubjudul,
        fontWeight: FontWeight.w700,
        color: AppTheme.warnaNavy,
      ),
      centerTitle: true,
      title: const Text('Upload stok'),
      shape: const Border(bottom: BorderSide(color: AppTheme.warnaGaris)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(_tinggiStepper),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.jarakBesar,
            AppTheme.jarakKecil,
            AppTheme.jarakBesar,
            AppTheme.jarakSedang,
          ),
          child: IndikatorLangkah(langkahAktif: langkahAktif),
        ),
      ),
    );
  }
}
