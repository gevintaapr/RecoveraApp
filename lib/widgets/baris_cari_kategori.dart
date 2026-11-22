import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'chip_kategori.dart';
import 'filter_sheet.dart';
import 'kolom_cari.dart';
import 'tombol_filter.dart';

// Di bawah header Katalog: kolom cari + tombol filter, lalu chip kategori bergulir.
// Nilai kategori yang dikirim ke server tetap nama aslinya (mis. "Flour & Grain");
// yang tampil adalah label Indonesia.
class BarisCariKategori extends StatelessWidget {
  final TextEditingController pencarianController;
  final FilterKatalog filter;
  final VoidCallback onCari;
  final VoidCallback onHapusCari;
  final VoidCallback onBukaFilter;
  final ValueChanged<String?> onPilihKategori;

  const BarisCariKategori({
    super.key,
    required this.pencarianController,
    required this.filter,
    required this.onCari,
    required this.onHapusCari,
    required this.onBukaFilter,
    required this.onPilihKategori,
  });

  // nilai server -> [label tampil, ikon]
  static const Map<String, (String, IconData)> daftarKategori = {
    'Frozen': ('Frozen', Icons.ac_unit),
    'Dairy': ('Susu', Icons.local_drink_outlined),
    'Flour & Grain': ('Tepung', Icons.grass),
    'Oil & Condiment': ('Minyak', Icons.water_drop_outlined),
    'Beverage': ('Minuman', Icons.local_cafe_outlined),
    'Canned & Preserved': ('Kalengan', Icons.kitchen_outlined),
    'General': ('Umum', Icons.category_outlined),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakTepi),
          child: Row(
            children: [
              Expanded(
                child: KolomCari(
                  controller: pencarianController,
                  petunjuk: 'Cari produk atau merek',
                  onCari: onCari,
                  onHapus: onHapusCari,
                ),
              ),
              const SizedBox(width: AppTheme.jarakKecil),
              TombolFilter(jumlahAktif: filter.jumlahFilterAktif, onPressed: onBukaFilter),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakTepi),
          child: Row(
            children: [
              ChipKategori(
                label: 'Semua',
                ikon: Icons.apps,
                terpilih: filter.kategori == null,
                onTap: () => onPilihKategori(null),
              ),
              for (final MapEntry<String, (String, IconData)> kategori in daftarKategori.entries) ...[
                const SizedBox(width: AppTheme.jarakKecil),
                ChipKategori(
                  label: kategori.value.$1,
                  ikon: kategori.value.$2,
                  terpilih: filter.kategori == kategori.key,
                  onTap: () => onPilihKategori(kategori.key),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
