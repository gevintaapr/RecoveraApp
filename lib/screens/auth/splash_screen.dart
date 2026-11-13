import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../shared/main_shell.dart';
import 'login_screen.dart';

// Layar pertama: tampil sebentar, lalu cek sesi di SharedPreferences.
// Sudah login -> MainShell sesuai peran. Belum -> Login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _cekSesi();
  }

  Future<void> _cekSesi() async {
    // Jeda singkat supaya logo sempat terlihat.
    await Future.delayed(const Duration(seconds: 2));
    final bool sudahLogin = await SessionService.sudahLogin();
    final String? peran = await SessionService.ambilPeran();
    if (!mounted) return;

    final Widget halamanTujuan = (sudahLogin && peran != null)
        ? MainShell(peran: peran)
        : const LoginScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => halamanTujuan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, size: AppTheme.ikonLogo, color: AppTheme.warnaUtama),
            SizedBox(height: AppTheme.jarakSedang),
            Text('Recovera', style: AppTheme.gayaJudul),
            SizedBox(height: AppTheme.jarakKecil),
            Text('Selamatkan pangan, kurangi limbah', style: AppTheme.gayaTeksRedup),
            SizedBox(height: AppTheme.jarakBesar),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
