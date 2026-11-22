import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Pita oranye saat yang tampil adalah cache Hive (server tidak bisa dihubungi).
// Dipakai di katalog; nanti juga di daftar pesanan.
class LabelDataOffline extends StatelessWidget {
  const LabelDataOffline({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.warnaAksen,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.jarakSedang,
        vertical: AppTheme.jarakKecil,
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, color: AppTheme.warnaPermukaan),
          SizedBox(width: AppTheme.jarakKecil),
          Expanded(
            child: Text(
              'Data offline: menampilkan data terakhir. Tarik ke bawah untuk mencoba lagi.',
              style: TextStyle(color: AppTheme.warnaPermukaan, fontSize: AppTheme.fontKecil),
            ),
          ),
        ],
      ),
    );
  }
}
