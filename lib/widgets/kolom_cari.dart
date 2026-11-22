import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Kolom pencarian kapsul putih bergaris (search bar Beranda Recovera lama).
// Tombol hapus muncul saat ada teks. Dipakai di Beranda dan Stok penjual.
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
    final OutlineInputBorder garis = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusKapsul),
      borderSide: const BorderSide(color: AppTheme.warnaGarisCari),
    );
    return SizedBox(
      height: AppTheme.ukuranTombolIkon,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onCari(),
        onChanged: onChanged,
        style: const TextStyle(fontSize: AppTheme.fontInput, fontWeight: FontWeight.w500, color: AppTheme.warnaNavy),
        decoration: InputDecoration(
          hintText: petunjuk,
          fillColor: warnaLatar,
          contentPadding: EdgeInsets.zero,
          border: garis,
          enabledBorder: garis,
          prefixIcon: const Icon(Icons.search_rounded, size: AppTheme.ikonMata, color: AppTheme.warnaTeksRedup),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  icon: const Icon(Icons.clear, size: AppTheme.ikonKecil),
                  onPressed: onHapus,
                ),
        ),
      ),
    );
  }
}
