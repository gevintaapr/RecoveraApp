import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Kolom pencarian berbentuk kapsul. Tombol hapus muncul saat ada teks.
// Dipakai di Katalog (cari produk) dan Stok penjual (cari stok).
class KolomCari extends StatelessWidget {
  final TextEditingController controller;
  final String petunjuk;
  final VoidCallback onCari;
  final VoidCallback onHapus;
  final Color warnaLatar;
  final ValueChanged<String>? onChanged; // diisi bila penyaringan langsung saat mengetik

  const KolomCari({
    super.key,
    required this.controller,
    required this.petunjuk,
    required this.onCari,
    required this.onHapus,
    this.warnaLatar = AppTheme.warnaPermukaan,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppTheme.tinggiInput,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onCari(),
        onChanged: onChanged,
        style: const TextStyle(fontSize: AppTheme.fontSedang, color: AppTheme.warnaTeks),
        decoration: InputDecoration(
          hintText: petunjuk,
          fillColor: warnaLatar,
          contentPadding: EdgeInsets.zero,
          prefixIcon: const Icon(Icons.search, size: AppTheme.ikonKecil, color: AppTheme.warnaTeksSedang),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  icon: const Icon(Icons.close, size: AppTheme.ikonKecil),
                  onPressed: onHapus,
                ),
        ),
      ),
    );
  }
}
