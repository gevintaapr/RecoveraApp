import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Baris pilihan radius di katalog: Semua / 5 km / 10 km / 25 km.
// Radius dikirim ke server (GET /listings?radius_km=...), server yang menyaring.
// Bila lokasi belum didapat, yang tampil pesan + tombol "Aktifkan lokasi".
class PilihanRadius extends StatelessWidget {
  final double? radiusTerpilih; // null = semua jarak
  final bool adaLokasi;
  final String? pesanLokasi;
  final ValueChanged<double?> onDipilih;
  final VoidCallback onAktifkanLokasi;

  const PilihanRadius({
    super.key,
    required this.radiusTerpilih,
    required this.adaLokasi,
    required this.pesanLokasi,
    required this.onDipilih,
    required this.onAktifkanLokasi,
  });

  static const List<double?> daftarRadius = [null, 5, 10, 25];

  @override
  Widget build(BuildContext context) {
    if (!adaLokasi) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
        child: Row(
          children: [
            const Icon(Icons.location_off_outlined, color: AppTheme.warnaTeksRedup),
            const SizedBox(width: AppTheme.jarakKecil),
            Expanded(
              child: Text(
                pesanLokasi ?? 'Lokasi belum aktif, jarak tidak ditampilkan.',
                style: AppTheme.gayaTeksRedup,
              ),
            ),
            TextButton(onPressed: onAktifkanLokasi, child: const Text('Aktifkan lokasi')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
      child: Row(
        children: daftarRadius.map((double? radius) {
          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.jarakKecil),
            child: ChoiceChip(
              label: Text(radius == null ? 'Semua jarak' : '≤ ${radius.round()} km'),
              selected: radiusTerpilih == radius,
              onSelected: (_) => onDipilih(radius),
            ),
          );
        }).toList(),
      ),
    );
  }
}
