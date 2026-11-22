import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'primary_button.dart';

// Data model untuk menampung kondisi filter & pengurutan katalog (T2).
class FilterKatalog {
  final String? kategori;
  final double? radiusKm;
  final int? maksSisaHari;
  final String urutan; // nearest, cheapest, expiring_soon, discount

  const FilterKatalog({
    this.kategori,
    this.radiusKm,
    this.maksSisaHari,
    this.urutan = 'nearest',
  });

  int get jumlahFilterAktif {
    int jumlah = 0;
    if (kategori != null) jumlah++;
    if (radiusKm != null) jumlah++;
    if (maksSisaHari != null) jumlah++;
    if (urutan != 'nearest') jumlah++;
    return jumlah;
  }

  FilterKatalog copyWith({
    String? Function()? kategori,
    double? Function()? radiusKm,
    int? Function()? maksSisaHari,
    String? urutan,
  }) {
    return FilterKatalog(
      kategori: kategori != null ? kategori() : this.kategori,
      radiusKm: radiusKm != null ? radiusKm() : this.radiusKm,
      maksSisaHari: maksSisaHari != null ? maksSisaHari() : this.maksSisaHari,
      urutan: urutan ?? this.urutan,
    );
  }
}

// Bottom sheet filter lanjutan & pengurutan katalog (T2).
Future<FilterKatalog?> tampilkanFilterSheet({
  required BuildContext context,
  required FilterKatalog filterSaatIni,
}) {
  return showModalBottomSheet<FilterKatalog>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _FilterSheetContent(filterAwal: filterSaatIni),
  );
}

class _FilterSheetContent extends StatefulWidget {
  final FilterKatalog filterAwal;

  const _FilterSheetContent({required this.filterAwal});

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  static const List<String> daftarKategori = [
    'Dairy',
    'Frozen',
    'Flour & Grain',
    'Oil & Condiment',
    'Beverage',
    'Canned & Preserved',
    'General',
  ];

  late String? _kategori;
  late double? _radiusKm;
  late int? _maksSisaHari;
  late String _urutan;

  @override
  void initState() {
    super.initState();
    _kategori = widget.filterAwal.kategori;
    _radiusKm = widget.filterAwal.radiusKm;
    _maksSisaHari = widget.filterAwal.maksSisaHari;
    _urutan = widget.filterAwal.urutan;
  }

  void _reset() {
    setState(() {
      _kategori = null;
      _radiusKm = null;
      _maksSisaHari = null;
      _urutan = 'nearest';
    });
  }

  void _terapkan() {
    final FilterKatalog hasil = FilterKatalog(
      kategori: _kategori,
      radiusKm: _radiusKm,
      maksSisaHari: _maksSisaHari,
      urutan: _urutan,
    );
    Navigator.pop(context, hasil);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.warnaPermukaan,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius * 2)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: AppTheme.jarakKecil, bottom: AppTheme.jarakKecil),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.warnaGaris,
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang, vertical: AppTheme.jarakKecil),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.tune_rounded, color: AppTheme.warnaUtama, size: 20),
                        SizedBox(width: AppTheme.jarakKecil),
                        Text('Filter & Urutkan', style: AppTheme.gayaSubjudul),
                      ],
                    ),
                    TextButton(
                      onPressed: _reset,
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          color: AppTheme.warnaUtama,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Filter Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppTheme.jarakSedang),
                  children: [
                    // 1. Urutkan Berdasarkan
                    _judulBagian('Urutkan Berdasarkan'),
                    Wrap(
                      spacing: AppTheme.jarakKecil,
                      runSpacing: AppTheme.jarakKecil,
                      children: [
                        _chipPilihan(label: 'Terdekat', terpilih: _urutan == 'nearest', onPilih: () => setState(() => _urutan = 'nearest')),
                        _chipPilihan(label: 'Termurah', terpilih: _urutan == 'cheapest', onPilih: () => setState(() => _urutan = 'cheapest')),
                        _chipPilihan(label: 'Segera Kedaluwarsa', terpilih: _urutan == 'expiring_soon', onPilih: () => setState(() => _urutan = 'expiring_soon')),
                        _chipPilihan(label: 'Diskon Tertinggi', terpilih: _urutan == 'discount', onPilih: () => setState(() => _urutan = 'discount')),
                      ],
                    ),
                    const SizedBox(height: AppTheme.jarakBesar),

                    // 2. Radius Jarak Gudang
                    _judulBagian('Radius Jarak Gudang'),
                    Wrap(
                      spacing: AppTheme.jarakKecil,
                      runSpacing: AppTheme.jarakKecil,
                      children: [
                        _chipPilihan(label: 'Semua Jarak', terpilih: _radiusKm == null, onPilih: () => setState(() => _radiusKm = null)),
                        _chipPilihan(label: '≤ 5 km', terpilih: _radiusKm == 5.0, onPilih: () => setState(() => _radiusKm = 5.0)),
                        _chipPilihan(label: '≤ 15 km', terpilih: _radiusKm == 15.0, onPilih: () => setState(() => _radiusKm = 15.0)),
                        _chipPilihan(label: '≤ 30 km', terpilih: _radiusKm == 30.0, onPilih: () => setState(() => _radiusKm = 30.0)),
                        _chipPilihan(label: '≤ 50 km', terpilih: _radiusKm == 50.0, onPilih: () => setState(() => _radiusKm = 50.0)),
                      ],
                    ),
                    const SizedBox(height: AppTheme.jarakBesar),

                    // 3. Sisa Umur Simpan (Kedaluwarsa)
                    _judulBagian('Sisa Waktu Kedaluwarsa'),
                    Wrap(
                      spacing: AppTheme.jarakKecil,
                      runSpacing: AppTheme.jarakKecil,
                      children: [
                        _chipPilihan(label: 'Semua Umur', terpilih: _maksSisaHari == null, onPilih: () => setState(() => _maksSisaHari = null)),
                        _chipPilihan(label: '≤ 14 Hari', terpilih: _maksSisaHari == 14, onPilih: () => setState(() => _maksSisaHari = 14)),
                        _chipPilihan(label: '≤ 30 Hari', terpilih: _maksSisaHari == 30, onPilih: () => setState(() => _maksSisaHari = 30)),
                        _chipPilihan(label: '≤ 60 Hari', terpilih: _maksSisaHari == 60, onPilih: () => setState(() => _maksSisaHari = 60)),
                      ],
                    ),
                    const SizedBox(height: AppTheme.jarakBesar),

                    // 4. Kategori Produk
                    _judulBagian('Kategori Produk'),
                    Wrap(
                      spacing: AppTheme.jarakKecil,
                      runSpacing: AppTheme.jarakKecil,
                      children: [
                        _chipPilihan(label: 'Semua Kategori', terpilih: _kategori == null, onPilih: () => setState(() => _kategori = null)),
                        ...daftarKategori.map((kat) => _chipPilihan(
                          label: kat,
                          terpilih: _kategori == kat,
                          onPilih: () => setState(() => _kategori = _kategori == kat ? null : kat),
                        )),
                      ],
                    ),
                    const SizedBox(height: AppTheme.jarakBesar),
                  ],
                ),
              ),

              // Tombol Terapkan
              Padding(
                padding: const EdgeInsets.all(AppTheme.jarakSedang),
                child: PrimaryButton(
                  teks: 'Terapkan Filter',
                  onPressed: _terapkan,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _judulBagian(String judul) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.jarakKecil),
      child: Text(
        judul,
        style: const TextStyle(
          fontSize: AppTheme.fontNormal,
          fontWeight: FontWeight.bold,
          color: AppTheme.warnaTeks,
        ),
      ),
    );
  }

  Widget _chipPilihan({
    required String label,
    required bool terpilih,
    required VoidCallback onPilih,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: terpilih,
      onSelected: (_) => onPilih(),
      selectedColor: AppTheme.warnaUtama.withValues(alpha: 0.15),
      backgroundColor: AppTheme.warnaLatar,
      labelStyle: TextStyle(
        fontSize: AppTheme.fontKecil,
        fontWeight: terpilih ? FontWeight.bold : FontWeight.normal,
        color: terpilih ? AppTheme.warnaUtama : AppTheme.warnaTeks,
      ),
      side: BorderSide(
        color: terpilih ? AppTheme.warnaUtama : AppTheme.warnaGaris,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius / 2),
      ),
    );
  }
}

