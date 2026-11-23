import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Stepper upload stok penjual: 1 Data Produk, 2 Review & Terbitkan.
// Selesai = hijau + centang, aktif = biru, sisanya putih bergaris abu.
class IndikatorLangkah extends StatelessWidget {
  final int langkahAktif; // 1 atau 2

  const IndikatorLangkah({super.key, required this.langkahAktif});

  static const List<String> _daftarLangkah = ['Data Produk', 'Review & Terbitkan'];

  @override
  Widget build(BuildContext context) {
    final List<Widget> isi = [];
    for (int i = 0; i < _daftarLangkah.length; i++) {
      final int nomor = i + 1;
      if (i > 0) isi.add(_GarisPenghubung(selesai: nomor <= langkahAktif));
      isi.add(_ItemLangkah(
        nomor: nomor,
        label: _daftarLangkah[i],
        aktif: nomor == langkahAktif,
        selesai: nomor < langkahAktif,
      ));
    }
    return Semantics(
      label: 'Langkah $langkahAktif dari ${_daftarLangkah.length}: ${_daftarLangkah[langkahAktif - 1]}',
      child: ExcludeSemantics(child: Row(children: isi)),
    );
  }
}

class _ItemLangkah extends StatelessWidget {
  final int nomor;
  final String label;
  final bool aktif;
  final bool selesai;

  const _ItemLangkah({required this.nomor, required this.label, required this.aktif, required this.selesai});

  @override
  Widget build(BuildContext context) {
    final bool terisi = aktif || selesai;
    // Hijau/biru versi gelap agar ikon & teks putih lolos kontras.
    final Color warna = selesai ? AppTheme.warnaSisaAman : AppTheme.warnaJarak;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppTheme.ukuranLingkaranLangkah,
          height: AppTheme.ukuranLingkaranLangkah,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: terisi ? warna : AppTheme.warnaPermukaan,
            border: terisi ? null : Border.all(color: AppTheme.warnaGarisCari, width: 1.5),
          ),
          child: selesai
              ? const Icon(Icons.check, size: AppTheme.fontSubjudul, color: AppTheme.warnaPermukaan)
              : Text(
                  '$nomor',
                  style: TextStyle(
                    fontSize: AppTheme.fontNormal,
                    fontWeight: FontWeight.w800,
                    color: terisi ? AppTheme.warnaPermukaan : AppTheme.warnaTeksRedup,
                  ),
                ),
        ),
        const SizedBox(height: AppTheme.jarakMini),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTheme.fontLabel,
            fontWeight: terisi ? FontWeight.w700 : FontWeight.w500,
            color: terisi ? warna : AppTheme.warnaTeksRedup,
          ),
        ),
      ],
    );
  }
}

class _GarisPenghubung extends StatelessWidget {
  final bool selesai;

  const _GarisPenghubung({required this.selesai});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        // Sejajarkan garis dengan tengah lingkaran, bukan dengan label.
        margin: const EdgeInsets.only(bottom: AppTheme.fontLabel + AppTheme.jarakKecil),
        color: selesai ? AppTheme.warnaJarak : AppTheme.warnaGaris,
      ),
    );
  }
}
