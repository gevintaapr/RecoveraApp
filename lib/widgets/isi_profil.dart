import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../screens/shared/notification_screen.dart';
import '../screens/shared/orders_screen.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import 'app_bar_transaksi.dart';
import 'menu_profil.dart';

// Isi halaman Profil di bawah header (tampilan Recovera lama):
// avatar melayang, nama usaha, "peran • kota", daftar menu, tombol Logout.
// Lokasi tampil "Nama Kota (lat, lng)". Kota penjual dari kolom city; pembeli
// tidak punya kolom kota, jadi dicari dari koordinat (LocationService.ambilNamaKota).
class IsiProfil extends StatefulWidget {
  final UserModel pengguna;
  final VoidCallback onKeluar;

  const IsiProfil({super.key, required this.pengguna, required this.onKeluar});

  @override
  State<IsiProfil> createState() => _IsiProfilState();
}

class _IsiProfilState extends State<IsiProfil> {
  Future<String>? _futureNamaKota;

  @override
  void initState() {
    super.initState();
    final UserModel pengguna = widget.pengguna;
    if (pengguna.latitude != null && pengguna.longitude != null) {
      final String? kotaTersimpan = pengguna.kota;
      _futureNamaKota = (kotaTersimpan != null && kotaTersimpan.isNotEmpty)
          ? Future<String>.value(kotaTersimpan)
          : LocationService.ambilNamaKota(
              pengguna.latitude!,
              pengguna.longitude!,
            );
    }
  }

  void _bukaPesanan() {
    final bool penjual = widget.pengguna.isPenjual;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBarTransaksi(judul: penjual ? 'Kelola Pesanan' : 'Riwayat Transaksi'),
          body: OrdersScreen(isPenjual: penjual),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserModel pengguna = widget.pengguna;
    final String namaUsaha = (pengguna.namaPerusahaan?.isNotEmpty == true)
        ? pengguna.namaPerusahaan!
        : pengguna.nama;
    final String peran = pengguna.isPenjual
        ? 'Distributor (Seller)'
        : 'UMKM Kuliner (Buyer)';

    return FutureBuilder<String>(
      future: _futureNamaKota,
      builder: (context, snapshot) {
        final String? kota = snapshot.data;
        final String teksLokasi = _futureNamaKota == null
            ? '-'
            : (kota == null
                  ? 'Mendeteksi kota...'
                  : LocationService.formatLokasi(
                      kota,
                      pengguna.latitude!,
                      pengguna.longitude!,
                    ));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              namaUsaha,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppTheme.fontNamaProfil,
                fontWeight: FontWeight.w700,
                color: AppTheme.warnaNavy,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppTheme.jarakMini),
            Text(
              '$peran • ${kota ?? '-'}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppTheme.fontInput,
                color: AppTheme.warnaTeksRedup,
              ),
            ),
            const SizedBox(height: AppTheme.jarakBesar + AppTheme.jarakKecil),
            MenuProfil(
              ikon: Icons.business_rounded,
              latarIkon: AppTheme.warnaIkonBiruMuda,
              warnaIkon: AppTheme.warnaUtama,
              label: 'Informasi Bisnis',
              subjudul: pengguna.isPenjual
                  ? 'PIC: ${pengguna.nama}'
                  : 'Jenis usaha: ${pengguna.jenisUsaha ?? '-'} · PIC: ${pengguna.nama}',
            ),
            MenuProfil(
              ikon: Icons.call_outlined,
              latarIkon: AppTheme.warnaIkonBiruMuda,
              warnaIkon: AppTheme.warnaUtama,
              label: 'Kontak',
              subjudul: '${pengguna.telepon ?? '-'} · ${pengguna.email}',
            ),
            MenuProfil(
              ikon: Icons.location_on_outlined,
              latarIkon: AppTheme.warnaIkonCyanMuda,
              warnaIkon: AppTheme.warnaSekunder,
              label: pengguna.isPenjual ? 'Lokasi Gudang' : 'Lokasi Usaha',
              subjudul: teksLokasi,
              warnaSubjudul: AppTheme.warnaTeksCyan,
            ),
            MenuProfil(
              ikon: Icons.receipt_long_rounded,
              latarIkon: AppTheme.warnaIkonBiruMuda,
              warnaIkon: AppTheme.warnaUtama,
              label: pengguna.isPenjual
                  ? 'Kelola Pesanan Masuk'
                  : 'Riwayat Transaksi',
              subjudul: pengguna.isPenjual
                  ? 'Pantau penjualan lot & serah terima batch'
                  : 'Pantau status pesanan & pengambilan',
              warnaSubjudul: AppTheme.warnaUtama,
              onTap: _bukaPesanan,
            ),
            // Menu Notifikasi hanya untuk penjual; pembeli membukanya dari header Beranda.
            if (pengguna.isPenjual)
              MenuProfil(
                ikon: Icons.notifications_none_rounded,
                latarIkon: AppTheme.warnaIkonBiruMuda,
                warnaIkon: AppTheme.warnaUtama,
                label: 'Notifikasi',
                subjudul: 'Pesanan masuk & pengingat',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                ),
              ),
            const SizedBox(height: AppTheme.jarakBesar),
            const Divider(color: AppTheme.warnaLatarNetral, thickness: 1.5),
            const SizedBox(height: AppTheme.jarakTepi),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.warnaGalatTeks,
                side: const BorderSide(
                  color: AppTheme.warnaGalatTeks,
                  width: 2,
                ),
                minimumSize: const Size.fromHeight(AppTheme.tinggiTombol),
              ),
              onPressed: widget.onKeluar,
              icon: const Icon(Icons.logout_rounded, size: AppTheme.ikonKecil),
              label: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
