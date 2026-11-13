import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Tombol utama yang dipakai ulang di banyak layar.
// Saat sedangMemuat = true, tombol menampilkan loading (buffer) dan tidak bisa
// ditekan, supaya proses tidak terkirim dua kali. onPressed null = tombol nonaktif.
class PrimaryButton extends StatelessWidget {
  final String teks;
  final VoidCallback? onPressed;
  final bool sedangMemuat;

  const PrimaryButton({
    super.key,
    required this.teks,
    required this.onPressed,
    this.sedangMemuat = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppTheme.tinggiTombol,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.warnaUtama,
          foregroundColor: AppTheme.warnaPermukaan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
        ),
        onPressed: sedangMemuat ? null : onPressed,
        child: sedangMemuat
            ? const SizedBox(
                width: AppTheme.jarakBesar,
                height: AppTheme.jarakBesar,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(teks, style: const TextStyle(fontSize: AppTheme.fontNormal)),
      ),
    );
  }
}
