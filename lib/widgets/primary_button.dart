import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Tombol utama kapsul biru dengan bayangan (PillButton Recovera lama).
// Saat sedangMemuat = true, tombol menampilkan loading (buffer) dan tidak bisa
// ditekan, supaya proses tidak terkirim dua kali. onPressed null = tombol nonaktif.
class PrimaryButton extends StatelessWidget {
  final String teks;
  final VoidCallback? onPressed;
  final bool sedangMemuat;
  final IconData? ikon;

  const PrimaryButton({
    super.key,
    required this.teks,
    required this.onPressed,
    this.sedangMemuat = false,
    this.ikon,
  });

  @override
  Widget build(BuildContext context) {
    final Widget isi = sedangMemuat
        ? const SizedBox(
            width: AppTheme.ikonSedang,
            height: AppTheme.ikonSedang,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.warnaPermukaan),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ikon != null) ...[
                Icon(ikon, size: AppTheme.ikonKecil),
                const SizedBox(width: AppTheme.jarakKecil),
              ],
              Flexible(child: Text(teks, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: AppTheme.tinggiTombol,
      child: ElevatedButton(
        onPressed: sedangMemuat ? null : onPressed,
        // Saat memuat tetap biru supaya tidak terlihat seperti tombol mati.
        style: sedangMemuat
            ? ElevatedButton.styleFrom(disabledBackgroundColor: AppTheme.warnaUtama)
            : null,
        child: isi,
      ),
    );
  }
}
