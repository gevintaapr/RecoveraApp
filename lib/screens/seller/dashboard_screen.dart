import 'package:flutter/material.dart';

import '../../models/listing_model.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar_transaksi.dart';
import '../../widgets/bar_aksi_cepat.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/header_dasbor.dart';
import '../../widgets/kartu_angka.dart';
import '../../widgets/kartu_pesanan_menunggu.dart';
import '../auth/login_screen.dart';
import '../shared/orders_screen.dart';
import 'listing_form_screen.dart';

// Tab Dasbor (penjual): header usaha, 4 angka ringkasan, tombol upload stok,
// pesanan yang perlu disiapkan, dan stok yang segera kedaluwarsa (T5).
// Data: ambilProfil + ambilInventaris + ambilDaftarPesanan lewat satu FutureBuilder.
// setState: saat ditarik ke bawah atau kembali dari layar lain (_muatUlang).
class DashboardScreen extends StatefulWidget {
  final VoidCallback? onPindahKeStok;

  const DashboardScreen({super.key, this.onPindahKeStok});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DataDasbor {
  final UserModel profil;
  final List<ListingModel> daftarStok;
  final List<OrderModel> daftarPesanan;

  _DataDasbor({required this.profil, required this.daftarStok, required this.daftarPesanan});
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<_DataDasbor> _futureDasbor;

  @override
  void initState() {
    super.initState();
    _futureDasbor = _ambilDataDasbor();
  }

  Future<_DataDasbor> _ambilDataDasbor() async {
    final UserModel profil = await ApiService.ambilProfil();
    final List<ListingModel> stok = await ApiService.ambilInventaris();
    final List<OrderModel> pesanan = await ApiService.ambilDaftarPesanan();
    return _DataDasbor(profil: profil, daftarStok: stok, daftarPesanan: pesanan);
  }

  Future<void> _muatUlang() async {
    final Future<_DataDasbor> permintaanBaru = _ambilDataDasbor();
    setState(() {
      _futureDasbor = permintaanBaru;
    });
    try {
      await permintaanBaru;
    } catch (_) {}
  }

  Future<void> _bukaSemuaPesanan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: const AppBarTransaksi(judul: 'Kelola Pesanan'),
          body: const OrdersScreen(isPenjual: true),
        ),
      ),
    );
    if (!mounted) return;
    await _muatUlang();
  }

  Future<void> _bukaUploadStok() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ListingFormScreen()),
    );
    if (!mounted) return;
    await _muatUlang();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DataDasbor>(
      future: _futureDasbor,
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

        final _DataDasbor data = snapshot.data!;
        final DateTime sekarang = DateTime.now();

        // Metrik dihitung dari data asli server, tidak ada angka contoh.
        final int stokAktif = data.daftarStok.where((l) => l.status == 'active').length;
        final int transaksiBulanIni = data.daftarPesanan
            .where((p) => p.dibuatPada.year == sekarang.year && p.dibuatPada.month == sekarang.month)
            .length;
        final List<ListingModel> segeraKedaluwarsa = data.daftarStok
            .where((l) => l.status == 'active' && l.sisaHari != null && l.sisaHari! <= 14)
            .toList();
        final List<OrderModel> perluDiproses = data.daftarPesanan.where((p) => p.status != 'completed').toList();

        return RefreshIndicator(
          onRefresh: _muatUlang,
          child: ListView(
            // Jarak bawah = tinggi bar navigasi kaca (extendBody) + jarak biasa.
            padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + AppTheme.jarakSedang),
            children: [
              HeaderDasbor(profil: data.profil),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppTheme.jarakBesar, AppTheme.jarakTepi, AppTheme.jarakBesar, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Kartu bento 2x2 (GridView, Modul II). Angka dari data server.
                    GridView.count(
                      crossAxisCount: 2,
                      // padding nol: tanpa ini GridView ikut menambah jarak bawah selebar bar navigasi.
                      padding: EdgeInsets.zero,
                      clipBehavior: Clip.none, // bayangan kartu baris bawah tidak terpotong
                      childAspectRatio: AppTheme.rasioKotakRingkasan,
                      mainAxisSpacing: AppTheme.jarakSedang,
                      crossAxisSpacing: AppTheme.jarakSedang,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        KartuAngka(
                          label: 'Stok Aktif',
                          nilai: '$stokAktif',
                          ikon: Icons.inventory,
                          keterangan: 'Lelang sedang tayang',
                          onTap: widget.onPindahKeStok,
                        ),
                        KartuAngka(
                          label: 'Transaksi Bulan Ini',
                          nilai: '$transaksiBulanIni',
                          ikon: Icons.receipt_long,
                          warna: AppTheme.warnaSukses,
                          keterangan: 'Pesanan bulan berjalan',
                        ),
                        KartuAngka(
                          label: 'Segera Kedaluwarsa',
                          nilai: '${segeraKedaluwarsa.length}',
                          ikon: Icons.warning_amber_rounded,
                          warna: AppTheme.warnaSisaSedang,
                          keterangan: '14 hari atau kurang',
                        ),
                        KartuAngka(
                          label: 'Perlu Diproses',
                          nilai: '${perluDiproses.length}',
                          ikon: Icons.pending_actions_rounded,
                          warna: AppTheme.warnaGalatTeks,
                          keterangan: 'Belum selesai diambil',
                          onTap: _bukaSemuaPesanan,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.jarakBesar),
                    BarAksiCepat(
                      onUploadStok: _bukaUploadStok,
                      onBukaStok: () => widget.onPindahKeStok?.call(),
                      onBukaPesanan: _bukaSemuaPesanan,
                    ),
                    const SizedBox(height: AppTheme.jarakBesar),
                    KartuPesananMenunggu(
                      daftarPesanan: perluDiproses,
                      onBerubah: _muatUlang,
                      onLihatSemua: _bukaSemuaPesanan,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

