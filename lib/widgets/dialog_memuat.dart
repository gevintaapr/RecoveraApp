import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// "Buffer" untuk aksi yang butuh waktu tapi tidak berasal dari PrimaryButton
// (mis. logout dari ikon, beli dari dialog). Selama proses berjalan, layar
// tertutup dialog loading sehingga pengguna tidak bisa menekan dua kali.
//
// Cara pakai:
//   tampilkanDialogMemuat(context, pesan: 'Memproses pembelian...');
//   await ApiService.beliSekarang(...);
//   if (!context.mounted) return;
//   Navigator.pop(context); // menutup dialog loading (Modul IV: pop)
void tampilkanDialogMemuat(BuildContext context, {String pesan = 'Memproses...'}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // tidak bisa ditutup dengan mengetuk luar dialog
    builder: (context) => PopScope(
      canPop: false, // tombol back HP juga tidak menutupnya
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: AppTheme.jarakSedang),
            Expanded(child: Text(pesan)),
          ],
        ),
      ),
    ),
  );
}
