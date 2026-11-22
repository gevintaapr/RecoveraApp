import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'kolom_kapsul.dart';

// Kolom akun di form Register (semua wajib): nama/PIC, email, password, PIN, telepon.
// Controller milik layar Register (yang juga men-dispose-nya); widget ini hanya
// menyimpan status tampil/sembunyi password (setState).
class DataAkunDaftar extends StatefulWidget {
  final TextEditingController namaController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController pinController;
  final TextEditingController teleponController;
  final String? Function(String?, String) wajibDiisi;

  const DataAkunDaftar({
    super.key,
    required this.namaController,
    required this.emailController,
    required this.passwordController,
    required this.pinController,
    required this.teleponController,
    required this.wajibDiisi,
  });

  @override
  State<DataAkunDaftar> createState() => _DataAkunDaftarState();
}

class _DataAkunDaftarState extends State<DataAkunDaftar> {
  bool sembunyikanPassword = true;

  @override
  Widget build(BuildContext context) {
    const SizedBox jarak = SizedBox(height: AppTheme.jarakAntarKolom);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KolomKapsul(
          label: 'Nama Lengkap / PIC',
          petunjuk: 'Contoh: Budi Santoso',
          controller: widget.namaController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: (nilai) => widget.wajibDiisi(nilai, 'Nama'),
        ),
        jarak,
        KolomKapsul(
          label: 'Email Address',
          petunjuk: 'kontak@perusahaan.com',
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (nilai) {
            if (nilai == null || nilai.trim().isEmpty) return 'Email wajib diisi';
            if (!nilai.contains('@')) return 'Format email tidak valid';
            return null;
          },
        ),
        jarak,
        KolomKapsul(
          label: 'Password',
          petunjuk: 'Minimal 8 karakter',
          controller: widget.passwordController,
          sembunyikanTeks: sembunyikanPassword,
          textInputAction: TextInputAction.next,
          ikonKanan: IconButton(
            tooltip: sembunyikanPassword ? 'Tampilkan password' : 'Sembunyikan password',
            onPressed: () => setState(() => sembunyikanPassword = !sembunyikanPassword),
            icon: Icon(
              sembunyikanPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: AppTheme.ikonMata,
              color: AppTheme.warnaTeksRedup,
            ),
          ),
          validator: (nilai) => (nilai == null || nilai.length < 8) ? 'Password minimal 8 karakter' : null,
        ),
        jarak,
        KolomKapsul(
          label: 'PIN Transaksi (6 angka)',
          petunjuk: 'Contoh: 123456',
          controller: widget.pinController,
          keyboardType: TextInputType.number,
          sembunyikanTeks: true,
          maxLength: 6,
          textInputAction: TextInputAction.next,
          validator: (nilai) => (nilai == null || nilai.length != 6 || int.tryParse(nilai) == null)
              ? 'PIN harus terdiri dari 6 angka'
              : null,
        ),
        jarak,
        KolomKapsul(
          label: 'No. Telepon',
          petunjuk: 'Contoh: 081234567890',
          controller: widget.teleponController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          validator: (nilai) => widget.wajibDiisi(nilai, 'No. telepon'),
        ),
      ],
    );
  }
}
