import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/notifikasi_controller.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/header_gelombang.dart';
import '../../widgets/isi_profil.dart';
import '../auth/login_screen.dart';

// Tab Profil (kedua peran), tampilan Recovera lama: header gelombang "Profil Saya",
// avatar melayang, identitas usaha, daftar menu, tombol Logout.
// Data: ApiService.ambilProfil() (GET /profile) lewat FutureBuilder.
// setState: saat ditarik ke bawah -> future diganti -> profil dimuat ulang.
// Logout: konfirmasi -> dialog loading -> ApiService.keluar() -> kembaliKeLogin.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserModel> _futureProfil;

  @override
  void initState() {
    super.initState();
    _futureProfil = ApiService.ambilProfil();
  }

  Future<void> _muatUlang() async {
    final Future<UserModel> permintaanBaru = ApiService.ambilProfil();
    setState(() {
      _futureProfil = permintaanBaru;
    });
    try {
      await permintaanBaru;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  Future<void> _keluar() async {
    final bool? yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusBesar)),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(fontSize: AppTheme.fontSubjudul, fontWeight: FontWeight.w700, color: AppTheme.warnaNavy),
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Recovera?', style: AppTheme.gayaTeksRedup),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warnaGalatTeks),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (yakin != true || !mounted) return;

    tampilkanDialogMemuat(context, pesan: 'Sedang keluar...');
    // Sesi lokal (termasuk last_notif_id) dihapus di dalam keluar().
    await ApiService.keluar();
    Get.find<NotifikasiController>().kosongkan(); // badge lonceng kembali 0
    if (!mounted) return;
    // pushAndRemoveUntil di dalamnya ikut menutup dialog loading.
    await kembaliKeLogin(context);
  }

  static const Widget _header = HeaderGelombang(
    child: SizedBox(
      height: AppTheme.tinggiJudulProfil,
      child: Center(
        child: Text(
          'Profil Saya',
          style: TextStyle(
            fontSize: AppTheme.fontSubjudul,
            fontWeight: FontWeight.w700,
            color: AppTheme.warnaPermukaan,
            letterSpacing: 0.2,
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _futureProfil,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(children: [_header, Expanded(child: Center(child: CircularProgressIndicator()))]);
        }
        if (snapshot.hasError) {
          final String pesan = snapshot.error.toString().replaceFirst('Exception: ', '');
          final bool sesiBerakhir = pesan == 'Sesi berakhir';
          return Column(
            children: [
              _header,
              Expanded(
                child: EmptyState(
                  ikon: sesiBerakhir ? Icons.lock_outline : Icons.wifi_off,
                  pesan: sesiBerakhir ? 'Sesi berakhir, silakan masuk lagi.' : pesan,
                  teksTombol: sesiBerakhir ? 'Masuk lagi' : 'Coba lagi',
                  onTombolDitekan: sesiBerakhir ? () => kembaliKeLogin(context) : _muatUlang,
                ),
              ),
            ],
          );
        }
        return RefreshIndicator(
          onRefresh: _muatUlang,
          child: ListView(
            // Jarak bawah = tinggi bottom nav mengambang (extendBody) + jarak biasa.
            padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + AppTheme.jarakBesar),
            children: [
              _header,
              // Avatar "melayang" di garis header: Align setinggi setengah avatar,
              // sehingga separuh atas avatar menumpuk ke header tanpa menyisakan ruang kosong.
              const Align(
                alignment: Alignment.bottomCenter,
                heightFactor: 0.5,
                child: _AvatarProfil(),
              ),
              const SizedBox(height: AppTheme.jarakSedang),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakAuthSisi),
                child: IsiProfil(pengguna: snapshot.data!, onKeluar: _keluar),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Avatar bulat bergradien dengan logo Recovera, bingkai putih, dan bayangan.
class _AvatarProfil extends StatelessWidget {
  const _AvatarProfil();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTheme.avatarProfil,
      height: AppTheme.avatarProfil,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.warnaPermukaan, width: 4),
        boxShadow: const [BoxShadow(color: AppTheme.warnaBayanganAvatar, blurRadius: 16, offset: Offset(0, 6))],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.warnaUtama, AppTheme.warnaSekunder],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: AppTheme.logoAvatar,
          color: AppTheme.warnaPermukaan,
        ),
      ),
    );
  }
}
