import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/local_db_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/header_auth.dart';
import '../../widgets/kartu_gelombang_auth.dart';
import '../../widgets/kolom_kapsul.dart';
import '../../widgets/primary_button.dart';
import '../shared/main_shell.dart';
import 'register_screen.dart';

// Dipakai saat logout dan saat server membalas "Sesi berakhir" (401):
// hapus sesi + cache pesanan (Hive), lalu pushAndRemoveUntil ke Login supaya semua halaman
// sebelumnya terhapus dan tombol back tidak kembali ke halaman yang butuh login.
Future<void> kembaliKeLogin(BuildContext context) async {
  await SessionService.hapusSesi();
  await LocalDbService.hapusCachePesanan();
  if (!context.mounted) return;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (route) => false,
  );
}

// Layar login (tampilan Recovera lama): header biru berlogo + kartu putih
// bergelombang berisi form email + password.
// Tombol "Login Akun" -> ApiService.masuk() -> sesi tersimpan -> MainShell sesuai peran.
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
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppTheme.warnaGalat,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool emailValid = emailController.text.contains('@');

    return Scaffold(
      body: Column(
        children: [
          HeaderAuth(
            // Cahaya putih di belakang logo (seperti Recovera lama) agar logo biru menonjol.
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.warnaCahayaLogo,
                    blurRadius: 48,
                    spreadRadius: 12,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/recovera-logo-mark.png',
                width: AppTheme.logoHeaderAuth,
                height: AppTheme.logoHeaderAuth,
                semanticLabel: 'Logo Recovera',
              ),
            ),
          ),
          Expanded(
            child: KartuGelombangAuth(
              child: Form(
                key: _kunciForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: AppTheme.fontSambutan,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.warnaNavy,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppTheme.jarakMini),
                    const Text(
                      'Halo, silakan login untuk melanjutkan.',
                      style: AppTheme.gayaTeksRedup,
                    ),
                    const SizedBox(height: AppTheme.jarakBesar),
                    KolomKapsul(
                      label: 'Email Address',
                      petunjuk: 'nama@perusahaan.com',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) =>
                          setState(() {}), // tanda centang muncul saat ada '@'
                      ikonKanan: emailValid ? const _TandaValid() : null,
                      validator: (nilai) {
                        if (nilai == null || nilai.trim().isEmpty) {
                          return 'Email wajib diisi';
                        }
                        if (!nilai.contains('@')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.jarakTepi),
                    KolomKapsul(
                      label: 'Password',
                      petunjuk: '••••••••',
                      controller: passwordController,
                      sembunyikanTeks: sembunyikanPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _masuk(),
                      ikonKanan: IconButton(
                        tooltip: sembunyikanPassword
                            ? 'Tampilkan password'
                            : 'Sembunyikan password',
                        onPressed: () => setState(
                          () => sembunyikanPassword = !sembunyikanPassword,
                        ),
                        icon: Icon(
                          sembunyikanPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: AppTheme.ikonMata,
                          color: AppTheme.warnaTeksRedup,
                        ),
                      ),
                      validator: (nilai) => (nilai == null || nilai.isEmpty)
                          ? 'Password wajib diisi'
                          : null,
                    ),
                    const SizedBox(
                      height: AppTheme.jarakBesar + AppTheme.jarakKecil,
                    ),
                    PrimaryButton(
                      teks: 'Login Akun',
                      sedangMemuat: sedangMemuat,
                      onPressed: _masuk,
                      // warna: AppTheme.warnaUtama
                    ),
                    const SizedBox(height: AppTheme.jarakBesar),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Belum punya akun?',
                            style: TextStyle(
                              fontSize: AppTheme.fontInput,
                              color: AppTheme.warnaTeksRedup,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            ),
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                fontSize: AppTheme.fontInput,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.warnaUtama,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Lingkaran hijau bercentang di ujung kolom email saat formatnya sudah benar.
class _TandaValid extends StatelessWidget {
  const _TandaValid();

  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: 1,
      child: Container(
        margin: const EdgeInsets.only(right: AppTheme.jarakKecil),
        width: AppTheme.tandaValid,
        height: AppTheme.tandaValid,
        decoration: const BoxDecoration(
          color: AppTheme.warnaLatarSukses,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: AppTheme.ikonCentang,
          color: AppTheme.warnaSukses,
        ),
      ),
    );
  }
}
