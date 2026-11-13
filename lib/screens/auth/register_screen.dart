import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../shared/main_shell.dart';

// Layar daftar akun. Pilihan peran menentukan field tambahan:
// - Penjual: nama perusahaan + kota
// - Pembeli: jenis usaha
// Lokasi gudang lewat GPS ditambahkan di langkah "lokasi".
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _kunciForm = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController namaPerusahaanController = TextEditingController();
  final TextEditingController kotaController = TextEditingController();

  String peranTerpilih = 'buyer';
  String jenisUsahaTerpilih = 'resto';
  bool sedangMemuat = false;

  // Nilai = yang dikirim ke backend, label = yang tampil.
  final Map<String, String> pilihanJenisUsaha = {
    'resto': 'Restoran',
    'hotel': 'Hotel',
    'katering': 'Katering',
    'kafe': 'Kafe',
  };

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    teleponController.dispose();
    namaPerusahaanController.dispose();
    kotaController.dispose();
    super.dispose();
  }

  bool get isPenjual => peranTerpilih == 'seller';

  // Kosong -> null, supaya backend memakai nilai bawaan.
  String? _isiAtauNull(TextEditingController controller) {
    final String teks = controller.text.trim();
    return teks.isEmpty ? null : teks;
  }

  Future<void> _daftar() async {
    if (!_kunciForm.currentState!.validate()) return;

    setState(() => sedangMemuat = true);
    try {
      final String peran = await ApiService.daftar(
        email: emailController.text.trim(),
        password: passwordController.text,
        peran: peranTerpilih,
        nama: namaController.text.trim(),
        telepon: _isiAtauNull(teleponController),
        namaPerusahaan: isPenjual ? namaPerusahaanController.text.trim() : null,
        kota: isPenjual ? _isiAtauNull(kotaController) : null,
        jenisUsaha: isPenjual ? null : jenisUsahaTerpilih,
      );
      if (!mounted) return;
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

  String? _wajibDiisi(String? nilai, String namaField) {
    if (nilai == null || nilai.trim().isEmpty) return '$namaField wajib diisi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.jarakBesar),
        child: Form(
          key: _kunciForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: peranTerpilih,
                decoration: const InputDecoration(labelText: 'Daftar sebagai'),
                items: const [
                  DropdownMenuItem(value: 'buyer', child: Text('Pembeli (resto, hotel, katering)')),
                  DropdownMenuItem(value: 'seller', child: Text('Penjual (distributor / gudang)')),
                ],
                onChanged: (nilai) => setState(() => peranTerpilih = nilai ?? 'buyer'),
              ),
              const SizedBox(height: AppTheme.jarakSedang),
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama lengkap'),
                validator: (nilai) => _wajibDiisi(nilai, 'Nama'),
              ),
              const SizedBox(height: AppTheme.jarakSedang),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (nilai) {
                  if (nilai == null || nilai.trim().isEmpty) return 'Email wajib diisi';
                  if (!nilai.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.jarakSedang),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password (min. 8 karakter)'),
                validator: (nilai) {
                  if (nilai == null || nilai.length < 8) return 'Password minimal 8 karakter';
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.jarakSedang),
              TextFormField(
                controller: teleponController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'No. telepon (opsional)'),
              ),
              const SizedBox(height: AppTheme.jarakSedang),
              // Field berbeda sesuai peran (berubah lewat setState saat dropdown diganti).
              if (isPenjual) ...[
                TextFormField(
                  controller: namaPerusahaanController,
                  decoration: const InputDecoration(labelText: 'Nama perusahaan'),
                  validator: (nilai) => _wajibDiisi(nilai, 'Nama perusahaan'),
                ),
                const SizedBox(height: AppTheme.jarakSedang),
                TextFormField(
                  controller: kotaController,
                  decoration: const InputDecoration(labelText: 'Kota gudang (opsional)'),
                ),
              ] else
                DropdownButtonFormField<String>(
                  initialValue: jenisUsahaTerpilih,
                  decoration: const InputDecoration(labelText: 'Jenis usaha'),
                  items: pilihanJenisUsaha.entries
                      .map((pilihan) => DropdownMenuItem(
                            value: pilihan.key,
                            child: Text(pilihan.value),
                          ))
                      .toList(),
                  onChanged: (nilai) =>
                      setState(() => jenisUsahaTerpilih = nilai ?? 'resto'),
                ),
              const SizedBox(height: AppTheme.jarakBesar),
              PrimaryButton(
                teks: 'Daftar',
                sedangMemuat: sedangMemuat,
                onPressed: _daftar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
