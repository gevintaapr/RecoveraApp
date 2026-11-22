import 'package:flutter/material.dart';

import '../screens/shared/main_shell.dart';
import '../services/session_service.dart';

// Tombol back yang selalu tampil di AppBar.
// - Ada halaman sebelumnya -> Navigator.pop.
// - Tidak ada (mis. dibuka dari pop-up notifikasi saat aplikasi baru dibuka)
//   -> pushAndRemoveUntil ke MainShell sesuai peran yang tersimpan di sesi.
class TombolKembali extends StatelessWidget {
  const TombolKembali({super.key});

  Future<void> _kembali(BuildContext context) async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    final String peran = await SessionService.ambilPeran() ?? 'buyer';
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainShell(peran: peran)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Kembali',
      icon: const Icon(Icons.arrow_back),
      onPressed: () => _kembali(context),
    );
  }
}
