import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'kolom_kapsul.dart';
import 'pilihan_kapsul.dart';

// Bagian form Register yang berubah sesuai peran (semua wajib):
// - Penjual: nama perusahaan + kota gudang
// - Pembeli: jenis usaha
// lalu tombol "Pilih lokasi di peta" yang menampilkan "Kota (lat, lng)" setelah dipilih.
class DataUsahaDaftar extends StatelessWidget {
  final bool isPenjual;
  final TextEditingController namaPerusahaanController;
  final TextEditingController kotaController;
  final String jenisUsaha;
  final Map<String, String> pilihanJenisUsaha;
  final ValueChanged<String?> onJenisUsahaBerubah;
  final String? teksLokasi; // null = belum diambil
  final VoidCallback onAmbilLokasi;
  final String? Function(String?, String) wajibDiisi;

  const DataUsahaDaftar({
    super.key,
    required this.isPenjual,
    required this.namaPerusahaanController,
    required this.kotaController,
    required this.jenisUsaha,
    required this.pilihanJenisUsaha,
    required this.onJenisUsahaBerubah,
    required this.teksLokasi,
    required this.onAmbilLokasi,
    required this.wajibDiisi,
  });

  @override
  Widget build(BuildContext context) {
    final bool sudahAda = teksLokasi != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isPenjual) ...[
          KolomKapsul(
            label: 'Nama Perusahaan',
            petunjuk: 'Contoh: PT Pangan Nusantara',
            controller: namaPerusahaanController,
            textInputAction: TextInputAction.next,
            validator: (nilai) => wajibDiisi(nilai, 'Nama perusahaan'),
          ),
          const SizedBox(height: AppTheme.jarakAntarKolom),
          KolomKapsul(
            label: 'Kota Gudang',
            petunjuk: 'Terisi otomatis dari GPS',
            controller: kotaController,
            validator: (nilai) => wajibDiisi(nilai, 'Kota gudang'),
          ),
        ] else
          PilihanKapsul(
            label: 'Jenis Usaha',
            nilai: jenisUsaha,
            pilihan: pilihanJenisUsaha,
            onChanged: onJenisUsahaBerubah,
          ),
        const SizedBox(height: AppTheme.jarakTepi),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppTheme.tinggiTombol),
            backgroundColor: sudahAda ? AppTheme.warnaLatarSukses : null,
            foregroundColor: sudahAda ? AppTheme.warnaNavy : AppTheme.warnaUtama,
            side: BorderSide(color: sudahAda ? AppTheme.warnaGarisSukses : AppTheme.warnaUtama),
          ),
          onPressed: onAmbilLokasi,
          icon: Icon(sudahAda ? Icons.check_circle_rounded : Icons.map_outlined, size: AppTheme.ikonMata),
          label: Text(
            sudahAda
                ? '${isPenjual ? 'Gudang' : 'Usaha'}: $teksLokasi'
                : (isPenjual ? 'Pilih lokasi gudang di peta' : 'Pilih lokasi usaha di peta'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
