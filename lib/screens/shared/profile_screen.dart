import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/notifikasi_controller.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/baris_info.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/empty_state.dart';
import '../auth/login_screen.dart';
import 'notification_screen.dart';

// Tab Profil (kedua peran).
// Data: ApiService.ambilProfil() (GET /profile) lewat FutureBuilder.
// setState: saat ditarik ke bawah -> future diganti -> profil dimuat ulang.
// Tombol Keluar: konfirmasi -> dialog loading -> ApiService.keluar()
// -> pushAndRemoveUntil ke Login (lewat kembaliKeLogin).
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
        title: const Text('Keluar dari akun?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Keluar')),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _futureProfil,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final String pesan = snapshot.error.toString().replaceFirst('Exception: ', '');
          final bool sesiBerakhir = pesan == 'Sesi berakhir';
          return EmptyState(
            ikon: sesiBerakhir ? Icons.lock_outline : Icons.wifi_off,
            pesan: sesiBerakhir ? 'Sesi berakhir, silakan masuk lagi.' : pesan,
            teksTombol: sesiBerakhir ? 'Masuk lagi' : 'Coba lagi',
            onTombolDitekan: sesiBerakhir ? () => kembaliKeLogin(context) : _muatUlang,
          );
        }
        final UserModel pengguna = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _muatUlang,
          child: ListView(
            // Jarak bawah ikut tinggi bar navigasi kaca (extendBody), agar tombol Keluar terlihat.
            padding: EdgeInsets.fromLTRB(
              AppTheme.jarakSedang,
              AppTheme.jarakSedang,
              AppTheme.jarakSedang,
              MediaQuery.paddingOf(context).bottom + AppTheme.jarakSedang,
            ),
            children: [
              _KepalaProfil(pengguna: pengguna),
              const SizedBox(height: AppTheme.jarakBesar),
              _KartuInfo(pengguna: pengguna),
              const SizedBox(height: AppTheme.jarakSedang),
              // Menu Notifikasi hanya untuk penjual. Pembeli membuka Favorit
              // dan Notifikasi lewat ikon di AppBar MainShell.
              if (pengguna.isPenjual) ...[
                Card(
                  color: AppTheme.warnaPermukaan,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_none),
                    title: const Text('Notifikasi'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.jarakBesar),
              ],
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.warnaGalat,
                  side: const BorderSide(color: AppTheme.warnaGalat),
                  minimumSize: const Size.fromHeight(AppTheme.tinggiTombol),
                ),
                onPressed: _keluar,
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Avatar huruf depan nama + nama + peran + email.
class _KepalaProfil extends StatelessWidget {
  final UserModel pengguna;

  const _KepalaProfil({required this.pengguna});

  @override
  Widget build(BuildContext context) {
    final String hurufDepan = pengguna.nama.isEmpty ? '?' : pengguna.nama[0].toUpperCase();
    return Column(
      children: [
        CircleAvatar(
          radius: AppTheme.ikonLogo / 2,
          backgroundColor: AppTheme.warnaUtama,
          child: Text(hurufDepan, style: AppTheme.gayaJudul.copyWith(color: AppTheme.warnaPermukaan)),
        ),
        const SizedBox(height: AppTheme.jarakKecil),
        Text(pengguna.nama, style: AppTheme.gayaSubjudul),
        Text(pengguna.email, style: AppTheme.gayaTeksRedup),
        const SizedBox(height: AppTheme.jarakKecil),
        Chip(
          avatar: Icon(pengguna.isPenjual ? Icons.store_outlined : Icons.shopping_bag_outlined),
          label: Text(pengguna.isPenjual ? 'Penjual' : 'Pembeli'),
        ),
      ],
    );
  }
}

// Data usaha: penjual (perusahaan, gudang) atau pembeli (jenis usaha).
// Lokasi ditampilkan "Nama Kota (lat, lng)". Nama kota penjual diambil dari
// profil (kolom city); pembeli tidak punya kolom kota, jadi dicari dari
// koordinat lewat LocationService.ambilNamaKota() (FutureBuilder).
class _KartuInfo extends StatefulWidget {
  final UserModel pengguna;

  const _KartuInfo({required this.pengguna});

  @override
  State<_KartuInfo> createState() => _KartuInfoState();
}

class _KartuInfoState extends State<_KartuInfo> {
  Future<String>? _futureNamaKota;

  @override
  void initState() {
    super.initState();
    final UserModel pengguna = widget.pengguna;
    if (pengguna.latitude != null && pengguna.longitude != null) {
      final String? kotaTersimpan = pengguna.kota;
      _futureNamaKota = (kotaTersimpan != null && kotaTersimpan.isNotEmpty)
          ? Future<String>.value(kotaTersimpan)
          : LocationService.ambilNamaKota(pengguna.latitude!, pengguna.longitude!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserModel pengguna = widget.pengguna;
    return Card(
      color: AppTheme.warnaPermukaan,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.jarakSedang),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pengguna.isPenjual ? 'Info Usaha & Gudang' : 'Info Usaha', style: AppTheme.gayaSubjudul),
            const SizedBox(height: AppTheme.jarakKecil),
            if (pengguna.isPenjual)
              BarisInfo(label: 'Perusahaan', nilai: pengguna.namaPerusahaan ?? '-')
            else
              BarisInfo(label: 'Jenis usaha', nilai: pengguna.jenisUsaha ?? '-'),
            BarisInfo(label: 'Telepon', nilai: pengguna.telepon ?? '-'),
            BarisInfo(label: 'Alamat', nilai: pengguna.alamat ?? '-'),
            FutureBuilder<String>(
              future: _futureNamaKota,
              builder: (context, snapshot) {
                String nilai = '-';
                if (_futureNamaKota != null) {
                  nilai = snapshot.hasData
                      ? LocationService.formatLokasi(
                          snapshot.data!, pengguna.latitude!, pengguna.longitude!)
                      : 'Mendeteksi kota...';
                }
                return BarisInfo(
                  label: pengguna.isPenjual ? 'Lokasi gudang' : 'Lokasi usaha',
                  nilai: nilai,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
