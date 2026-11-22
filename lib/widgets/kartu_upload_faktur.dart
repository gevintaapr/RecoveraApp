import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Tombol besar bergradien: aksi utama penjual di dasbor.
class KartuUploadFaktur extends StatelessWidget {
  final VoidCallback onTap;

  const KartuUploadFaktur({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.gradienUtama,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.jarakSedang),
            child: Row(
              children: [
                Container(
                  width: AppTheme.ukuranTombolIkon,
                  height: AppTheme.ukuranTombolIkon,
                  decoration: BoxDecoration(
                    color: AppTheme.warnaKaca,
                    borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    color: AppTheme.warnaPermukaan,
                  ),
                ),
                const SizedBox(width: AppTheme.jarakSedang),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload stok dari faktur',
                        style: TextStyle(
                          fontSize: AppTheme.fontSedang,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.warnaPermukaan,
                        ),
                      ),
                      Text(
                        'Foto faktur, isi form dibaca otomatis',
                        style: TextStyle(
                          fontSize: AppTheme.fontKecil,
                          color: AppTheme.warnaPermukaan,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.warnaPermukaan),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
