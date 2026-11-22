import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'filter_sheet.dart';

// Header katalog pembeli: sapaan pengguna, lokasi, kolom cari,
// tombol buka filter dengan badge, dan chip kategori horizontal (T2).
class HeaderKatalog extends StatelessWidget {
  final String namaPengguna;
  final bool adaLokasi;
  final String? pesanLokasi;
  final String? namaKota;
  final TextEditingController pencarianController;
  final FilterKatalog filter;
  final VoidCallback onCari;
  final VoidCallback onHapusCari;
  final VoidCallback onBukaFilter;
  final ValueChanged<String?> onPilihKategori;

  const HeaderKatalog({
    super.key,
    required this.namaPengguna,
    required this.adaLokasi,
    required this.pesanLokasi,
    this.namaKota,
    required this.pencarianController,
    required this.filter,
    required this.onCari,
    required this.onHapusCari,
    required this.onBukaFilter,
    required this.onPilihKategori,
  });

  static const List<String> daftarKategori = [
    'Dairy',
    'Frozen',
    'Flour & Grain',
    'Oil & Condiment',
    'Beverage',
    'Canned & Preserved',
    'General',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sapaan & Lokasi Pengguna
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.jarakSedang,
            AppTheme.jarakKecil,
            AppTheme.jarakSedang,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${namaPengguna.isNotEmpty ? namaPengguna : 'Pelaku Usaha'} 👋',
                style: AppTheme.gayaSubjudul.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: adaLokasi ? AppTheme.warnaUtama : AppTheme.warnaTeksRedup,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      adaLokasi
                          ? (namaKota != null && namaKota!.isNotEmpty
                              ? namaKota!
                              : 'Mendeteksi nama kota...')
                          : (pesanLokasi ?? 'Mendeteksi lokasi terdekat...'),
                      style: const TextStyle(
                        fontSize: AppTheme.fontKecil,
                        color: AppTheme.warnaTeksRedup,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.jarakKecil),

        // Baris Pencarian & Tombol Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: pencarianController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => onCari(),
                  decoration: InputDecoration(
                    hintText: 'Cari produk pangan, distributor...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: pencarianController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: onHapusCari,
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.jarakSedang,
                      vertical: AppTheme.jarakKecil,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.jarakKecil),
              // Tombol Buka Filter Sheet
              Badge(
                isLabelVisible: filter.jumlahFilterAktif > 0,
                label: Text('${filter.jumlahFilterAktif}'),
                backgroundColor: AppTheme.warnaAksen,
                child: Container(
                  decoration: BoxDecoration(
                    color: filter.jumlahFilterAktif > 0
                        ? AppTheme.warnaUtama.withValues(alpha: 0.1)
                        : AppTheme.warnaPermukaan,
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    border: Border.all(
                      color: filter.jumlahFilterAktif > 0
                          ? AppTheme.warnaUtama
                          : AppTheme.warnaGaris,
                    ),
                  ),
                  child: IconButton(
                    tooltip: 'Filter & Urutkan',
                    icon: Icon(
                      Icons.tune_rounded,
                      color: filter.jumlahFilterAktif > 0
                          ? AppTheme.warnaUtama
                          : AppTheme.warnaTeks,
                    ),
                    onPressed: onBukaFilter,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.jarakKecil),

        // Kategori Horizontal Scrollable Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
          child: Row(
            children: [
              _buildCategoryChip(
                label: 'Semua',
                terpilih: filter.kategori == null,
                onTap: () => onPilihKategori(null),
              ),
              ...daftarKategori.map(
                (kat) => _buildCategoryChip(
                  label: kat,
                  terpilih: filter.kategori == kat,
                  onTap: () => onPilihKategori(kat),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool terpilih,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.jarakKecil),
      child: FilterChip(
        label: Text(label),
        selected: terpilih,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.warnaUtama.withValues(alpha: 0.15),
        checkmarkColor: AppTheme.warnaUtama,
        labelStyle: TextStyle(
          fontSize: AppTheme.fontKecil,
          fontWeight: terpilih ? FontWeight.bold : FontWeight.normal,
          color: terpilih ? AppTheme.warnaUtama : AppTheme.warnaTeks,
        ),
        backgroundColor: AppTheme.warnaPermukaan,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          side: BorderSide(
            color: terpilih ? AppTheme.warnaUtama : AppTheme.warnaGaris,
          ),
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

