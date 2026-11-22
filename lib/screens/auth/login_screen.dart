import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/local_db_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/header_gelombang.dart';
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
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppTheme.warnaGalat,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HeaderGelombang(child: _JudulAplikasi()),
            // Kartu form sedikit menumpuk ke header; bayangan menandai ia berada di atas.
            Transform.translate(
              offset: const Offset(0, -AppTheme.jarakBesar),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakBesar),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.jarakBesar),
                  decoration: BoxDecoration(
                    color: AppTheme.warnaPermukaan,
                    borderRadius: BorderRadius.circular(AppTheme.radiusBesar),
                    border: Border.all(color: AppTheme.warnaGaris),
                    boxShadow: const [
                      BoxShadow(color: AppTheme.warnaBayangan, blurRadius: AppTheme.jarakBesar, offset: Offset(0, AppTheme.jarakKecil)),
                    ],
                  ),
                  child: _formMasuk(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formMasuk() {
    return Form(
      key: _kunciForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Masuk ke akun',
            style: TextStyle(fontSize: AppTheme.fontBesar, fontWeight: FontWeight.w800, color: AppTheme.warnaNavy),
          ),
          const Text(
            'Gunakan email bisnis yang terdaftar.',
            style: TextStyle(fontSize: AppTheme.fontNormal, color: AppTheme.warnaTeksRedup),
          ),
          const SizedBox(height: AppTheme.jarakBesar),
          const _LabelKolom('Email'),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              hintText: 'email@usahaanda.com',
              fillColor: AppTheme.warnaLatar,
              prefixIcon: Icon(Icons.mail_outline, size: AppTheme.ikonKecil),
            ),
            validator: (nilai) {
              if (nilai == null || nilai.trim().isEmpty) return 'Email wajib diisi';
              if (!nilai.contains('@')) return 'Format email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: AppTheme.jarakSedang),
          const _LabelKolom('Password'),
          TextFormField(
            controller: passwordController,
            obscureText: sembunyikanPassword,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              hintText: 'Minimal 8 karakter',
              fillColor: AppTheme.warnaLatar,
              prefixIcon: const Icon(Icons.lock_outline, size: AppTheme.ikonKecil),
              suffixIcon: IconButton(
                tooltip: sembunyikanPassword ? 'Tampilkan password' : 'Sembunyikan password',
                icon: Icon(sembunyikanPassword ? Icons.visibility_off : Icons.visibility, size: AppTheme.ikonKecil),
                onPressed: () => setState(() => sembunyikanPassword = !sembunyikanPassword),
              ),
            ),
            validator: (nilai) => (nilai == null || nilai.isEmpty) ? 'Password wajib diisi' : null,
          ),
          const SizedBox(height: AppTheme.jarakBesar),
          PrimaryButton(teks: 'Masuk', sedangMemuat: sedangMemuat, onPressed: _masuk),
          const SizedBox(height: AppTheme.jarakKecil),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            ),
            child: const Text('Belum punya akun? Daftar'),
          ),
        ],
      ),
    );
  }
}

class _JudulAplikasi extends StatelessWidget {
  const _JudulAplikasi();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: AppTheme.jarakBesar, bottom: AppTheme.jarakBesar),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recovera',
            style: TextStyle(fontSize: AppTheme.fontJudul, fontWeight: FontWeight.w800, color: AppTheme.warnaPermukaan),
          ),
          SizedBox(height: AppTheme.jarakMini),
          Text(
            'Lelang stok pangan mendekati kedaluwarsa untuk resto, hotel, dan katering.',
            style: TextStyle(fontSize: AppTheme.fontSedang, color: AppTheme.warnaPermukaan),
          ),
        ],
      ),
    );
  }
}

// Label di atas kolom isian (bukan label mengambang) sesuai desain.
class _LabelKolom extends StatelessWidget {
  final String teks;

  const _LabelKolom(this.teks);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.jarakMini),
      child: Text(
        teks,
        style: const TextStyle(fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w700, color: AppTheme.warnaTeksSedang),
      ),
    );
  }
}
