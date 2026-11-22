import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';

import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/primary_button.dart';
import '../shared/main_shell.dart';

// Layar daftar akun. Semua kolom wajib diisi.
// Pilihan peran menentukan field tambahan:
// - Penjual: nama perusahaan + kota gudang + lokasi gudang (GPS)
// - Pembeli: jenis usaha + lokasi usaha (GPS)
// Lokasi tampil dengan format "Nama Kota (lat, lng)".
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
  final TextEditingController pinController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController namaPerusahaanController =
      TextEditingController();
  final TextEditingController kotaController = TextEditingController();

  String peranTerpilih = 'buyer';
  String jenisUsahaTerpilih = 'resto';
  bool sedangMemuat = false;
  // Koordinat gudang (penjual) / lokasi usaha (pembeli) dari GPS. Wajib diambil.
  double? latUsaha;
  double? lngUsaha;
  String namaKotaUsaha = '';

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
    pinController.dispose();
    teleponController.dispose();
    namaPerusahaanController.dispose();
    kotaController.dispose();
    super.dispose();
  }

  bool get isPenjual => peranTerpilih == 'seller';

  Future<void> _daftar() async {
    if (!_kunciForm.currentState!.validate()) return;
    if (latUsaha == null || lngUsaha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPenjual
                ? 'Lokasi gudang wajib diambil'
                : 'Lokasi usaha wajib diambil',
          ),
          backgroundColor: AppTheme.warnaGalat,
        ),
      );
      return;
    }

    setState(() => sedangMemuat = true);
    try {
      final String peran = await ApiService.daftar(
        email: emailController.text.trim(),
        password: passwordController.text,
        peran: peranTerpilih,
        nama: namaController.text.trim(),
        telepon: teleponController.text.trim(),
        namaPerusahaan: isPenjual ? namaPerusahaanController.text.trim() : null,
        kota: isPenjual ? kotaController.text.trim() : null,
        jenisUsaha: isPenjual ? null : jenisUsahaTerpilih,
        latitude: latUsaha,
        longitude: lngUsaha,
      );
      // Simpan PIN transaksi ke SharedPreferences (Modul VI)
      await SessionService.simpanPin(pinController.text.trim());
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
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppTheme.warnaGalat,
        ),
      );
    }
  }

  // Tombol "Gunakan lokasi saat ini": dialog loading -> GPS -> deteksi nama kota & koordinat.
  // Untuk penjual, kolom kota gudang otomatis diisi kota yang terdeteksi.
  Future<void> _ambilLokasiUsaha() async {
    tampilkanDialogMemuat(context, pesan: 'Mendeteksi lokasi & kota...');
    try {
      final Position posisi = await LocationService.ambilLokasiSaatIni();
      final String namaKota = await LocationService.ambilNamaKota(
        posisi.latitude,
        posisi.longitude,
      );
      if (!mounted) return;
      Navigator.pop(context); // tutup dialog loading
      setState(() {
        latUsaha = posisi.latitude;
        lngUsaha = posisi.longitude;
        namaKotaUsaha = namaKota;
        kotaController.text =
            namaKota; // Mengganti kota sebelumnya secara otomatis
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lokasi terdeteksi: ${LocationService.formatLokasi(namaKota, posisi.latitude, posisi.longitude)}',
          ),
          backgroundColor: AppTheme.warnaUtama,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppTheme.warnaGalat,
        ),
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
      appBar: AppBar(title: const Text('Daftar akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.jarakSedang),
        // Kartu putih yang sama dengan form Login, tanpa bayangan (tidak menumpuk header).
        child: Container(
          padding: const EdgeInsets.all(AppTheme.jarakBesar),
          decoration: BoxDecoration(
            color: AppTheme.warnaPermukaan,
            borderRadius: BorderRadius.circular(AppTheme.radiusBesar),
            border: Border.all(color: AppTheme.warnaGaris),
          ),
          child: Form(
            key: _kunciForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Semua kolom wajib diisi, termasuk lokasi usaha dari GPS.',
                  style: TextStyle(
                    fontSize: AppTheme.fontNormal,
                    color: AppTheme.warnaTeksRedup,
                  ),
                ),
                const SizedBox(height: AppTheme.jarakSedang),
                DropdownButtonFormField<String>(
                  initialValue: peranTerpilih,
                  decoration: const InputDecoration(
                    labelText: 'Daftar sebagai',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'buyer',
                      child: Text('Pembeli (resto, hotel, katering)'),
                    ),
                    DropdownMenuItem(
                      value: 'seller',
                      child: Text('Penjual (distributor / gudang)'),
                    ),
                  ],
                  onChanged: (nilai) =>
                      setState(() => peranTerpilih = nilai ?? 'buyer'),
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
                    if (nilai == null || nilai.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!nilai.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.jarakSedang),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password (min. 8 karakter)',
                  ),
                  validator: (nilai) {
                    if (nilai == null || nilai.length < 8) {
                      return 'Password minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.jarakSedang),
                TextFormField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'PIN Transaksi (6 digit angka)',
                    hintText: 'Misal: 123456',
                    counterText: '',
                    prefixIcon: Icon(Icons.pin_outlined),
                  ),
                  validator: (nilai) {
                    if (nilai == null ||
                        nilai.length != 6 ||
                        int.tryParse(nilai) == null) {
                      return 'PIN harus terdiri dari 6 angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.jarakSedang),
                TextFormField(
                  controller: teleponController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'No. telepon'),
                  validator: (nilai) => _wajibDiisi(nilai, 'No. telepon'),
                ),
                const SizedBox(height: AppTheme.jarakSedang),
                // Field berbeda sesuai peran (berubah lewat setState saat dropdown diganti).
                if (isPenjual) ...[
                  TextFormField(
                    controller: namaPerusahaanController,
                    decoration: const InputDecoration(
                      labelText: 'Nama perusahaan',
                    ),
                    validator: (nilai) => _wajibDiisi(nilai, 'Nama perusahaan'),
                  ),
                  const SizedBox(height: AppTheme.jarakSedang),
                  TextFormField(
                    controller: kotaController,
                    decoration: const InputDecoration(labelText: 'Kota gudang'),
                    validator: (nilai) => _wajibDiisi(nilai, 'Kota gudang'),
                  ),
                ] else
                  DropdownButtonFormField<String>(
                    initialValue: jenisUsahaTerpilih,
                    decoration: const InputDecoration(labelText: 'Jenis usaha'),
                    items: pilihanJenisUsaha.entries
                        .map(
                          (pilihan) => DropdownMenuItem(
                            value: pilihan.key,
                            child: Text(pilihan.value),
                          ),
                        )
                        .toList(),
                    onChanged: (nilai) =>
                        setState(() => jenisUsahaTerpilih = nilai ?? 'resto'),
                  ),
                const SizedBox(height: AppTheme.jarakSedang),
                // Lokasi wajib untuk kedua peran: gudang (penjual) / usaha (pembeli).
                OutlinedButton.icon(
                  onPressed: _ambilLokasiUsaha,
                  icon: const Icon(Icons.my_location),
                  label: Text(
                    latUsaha == null
                        ? (isPenjual
                              ? 'Gunakan lokasi saat ini sebagai gudang'
                              : 'Gunakan lokasi saat ini sebagai lokasi usaha')
                        : '${isPenjual ? 'Gudang' : 'Usaha'}: '
                              '${LocationService.formatLokasi(namaKotaUsaha, latUsaha!, lngUsaha!)}',
                  ),
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
      ),
    );
  }
}
