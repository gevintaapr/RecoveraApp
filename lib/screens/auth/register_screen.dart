import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/data_akun_daftar.dart';
import '../../widgets/data_usaha_daftar.dart';
import '../../widgets/header_auth.dart';
import '../../widgets/kartu_gelombang_auth.dart';
import '../../widgets/lencana_pendaftaran.dart';
import '../../widgets/pilihan_kapsul.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/tombol_ikon_header.dart';
import '../shared/main_shell.dart';
import 'pilih_lokasi_screen.dart';

// Layar daftar akun (tampilan Recovera lama): header biru + kartu putih bergelombang.
// Semua kolom wajib diisi. Pilihan peran menentukan field tambahan:
// - Penjual: nama perusahaan + kota gudang + lokasi gudang (dipilih di peta)
// - Pembeli: jenis usaha + lokasi usaha (dipilih di peta)
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
  final TextEditingController namaPerusahaanController = TextEditingController();
  final TextEditingController kotaController = TextEditingController();

  String peranTerpilih = 'buyer';
  String jenisUsahaTerpilih = 'resto';
  bool sedangMemuat = false;
  // Koordinat gudang (penjual) / lokasi usaha (pembeli) dari GPS. Wajib diambil.
  double? latUsaha;
  double? lngUsaha;
  String namaKotaUsaha = '';

  // Nilai = yang dikirim ke backend, label = yang tampil.
  static const Map<String, String> pilihanPeran = {
    'buyer': 'Pembeli (resto, hotel, katering)',
    'seller': 'Penjual (distributor / gudang)',
  };
  static const Map<String, String> pilihanJenisUsaha = {
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
          content: Text(isPenjual ? 'Lokasi gudang wajib diambil' : 'Lokasi usaha wajib diambil'),
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

  // Tombol lokasi: buka peta (Navigator.push) -> pengguna memilih titik ->
  // TitikLokasi dikembalikan lewat Navigator.pop -> setState menyimpan koordinat & kota.
  // Untuk penjual, kolom kota gudang otomatis diisi kota hasil pilihan.
  Future<void> _pilihLokasiDiPeta() async {
    final TitikLokasi? hasil = await Navigator.push<TitikLokasi>(
      context,
      MaterialPageRoute(
        builder: (context) => PilihLokasiScreen(
          judul: isPenjual ? 'Pilih Lokasi Gudang' : 'Pilih Lokasi Usaha',
          awal: latUsaha == null ? null : TitikLokasi(lat: latUsaha!, lng: lngUsaha!, kota: namaKotaUsaha),
        ),
      ),
    );
    if (hasil == null || !mounted) return;
    setState(() {
      latUsaha = hasil.lat;
      lngUsaha = hasil.lng;
      namaKotaUsaha = hasil.kota;
      kotaController.text = hasil.kota;
    });
  }

  String? _wajibDiisi(String? nilai, String namaField) {
    if (nilai == null || nilai.trim().isEmpty) return '$namaField wajib diisi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const SizedBox jarak = SizedBox(height: AppTheme.jarakAntarKolom);
    return Scaffold(
      body: Column(
        children: [
          HeaderAuth(
            tombolKiri: TombolIkonHeader(
              ikon: Icons.arrow_back_ios_new_rounded,
              keterangan: 'Kembali ke Login',
              onTap: () => Navigator.maybePop(context),
            ),
            child: const LencanaPendaftaran(),
          ),
          Expanded(
            child: KartuGelombangAuth(
              child: Form(
                key: _kunciForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Halo!',
                      style: TextStyle(
                        fontSize: AppTheme.fontSambutan,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.warnaNavy,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      'Buat akun Recovera untuk melanjutkan. Semua kolom wajib diisi.',
                      style: TextStyle(fontSize: AppTheme.fontInput, color: AppTheme.warnaTeksRedup),
                    ),
                    const SizedBox(height: AppTheme.jarakBesar),
                    PilihanKapsul(
                      label: 'Daftar sebagai',
                      nilai: peranTerpilih,
                      pilihan: pilihanPeran,
                      onChanged: (nilai) => setState(() => peranTerpilih = nilai ?? 'buyer'),
                    ),
                    jarak,
                    DataAkunDaftar(
                      namaController: namaController,
                      emailController: emailController,
                      passwordController: passwordController,
                      pinController: pinController,
                      teleponController: teleponController,
                      wajibDiisi: _wajibDiisi,
                    ),
                    jarak,
                    DataUsahaDaftar(
                      isPenjual: isPenjual,
                      namaPerusahaanController: namaPerusahaanController,
                      kotaController: kotaController,
                      jenisUsaha: jenisUsahaTerpilih,
                      pilihanJenisUsaha: pilihanJenisUsaha,
                      onJenisUsahaBerubah: (nilai) => setState(() => jenisUsahaTerpilih = nilai ?? 'resto'),
                      teksLokasi: latUsaha == null
                          ? null
                          : LocationService.formatLokasi(namaKotaUsaha, latUsaha!, lngUsaha!),
                      onAmbilLokasi: _pilihLokasiDiPeta,
                      wajibDiisi: _wajibDiisi,
                    ),
                    const SizedBox(height: AppTheme.jarakBesar),
                    PrimaryButton(teks: 'Buat Akun', sedangMemuat: sedangMemuat, onPressed: _daftar),
                    const SizedBox(height: AppTheme.jarakKecil),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun?',
                          style: TextStyle(fontSize: AppTheme.fontInput, color: AppTheme.warnaTeksRedup),
                        ),
                        TextButton(
                          onPressed: () => Navigator.maybePop(context),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: AppTheme.fontInput,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.warnaUtama,
                            ),
                          ),
                        ),
                      ],
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
