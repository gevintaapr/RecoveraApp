import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../shared/main_shell.dart';
import 'register_screen.dart';

// Dipakai saat logout dan saat server membalas "Sesi berakhir" (401):
// hapus sesi, lalu pushAndRemoveUntil ke Login supaya semua halaman
// sebelumnya terhapus dan tombol back tidak kembali ke halaman yang butuh login.
Future<void> kembaliKeLogin(BuildContext context) async {
  await SessionService.hapusSesi();
  if (!context.mounted) return;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (route) => false,
  );
}

// Layar login: form email + password.
// Tombol Masuk -> ApiService.masuk() -> sesi tersimpan -> MainShell sesuai peran.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _kunciForm = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool sedangMemuat = false;
  bool sembunyikanPassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    if (!_kunciForm.currentState!.validate()) return;

    setState(() => sedangMemuat = true);
    try {
      final String peran = await ApiService.masuk(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (!mounted) return;
      // pushAndRemoveUntil: halaman login dibuang, tombol back tidak kembali ke sini.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainShell(peran: peran)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => sedangMemuat = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.jarakBesar),
            child: Form(
              key: _kunciForm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.eco, size: AppTheme.ikonLogo, color: AppTheme.warnaUtama),
                  const SizedBox(height: AppTheme.jarakSedang),
                  const Text('Masuk ke Recovera',
                      style: AppTheme.gayaJudul, textAlign: TextAlign.center),
                  const SizedBox(height: AppTheme.jarakBesar),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (nilai) {
                      if (nilai == null || nilai.trim().isEmpty) return 'Email wajib diisi';
                      if (!nilai.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.jarakSedang),
                  TextFormField(
                    controller: passwordController,
                    obscureText: sembunyikanPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(sembunyikanPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                            () => sembunyikanPassword = !sembunyikanPassword),
                      ),
                    ),
                    validator: (nilai) =>
                        (nilai == null || nilai.isEmpty) ? 'Password wajib diisi' : null,
                  ),
                  const SizedBox(height: AppTheme.jarakBesar),
                  PrimaryButton(
                    teks: 'Masuk',
                    sedangMemuat: sedangMemuat,
                    onPressed: _masuk,
                  ),
                  const SizedBox(height: AppTheme.jarakSedang),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    ),
                    child: const Text('Belum punya akun? Daftar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
