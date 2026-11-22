import 'package:flutter/material.dart';

import '../../models/listing_model.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/header_dasbor.dart';
import '../../widgets/judul_bagian.dart';
import '../../widgets/kartu_angka.dart';
import '../../widgets/kartu_pesanan.dart';
import '../../widgets/kartu_stok_kedaluwarsa.dart';
import '../../widgets/kartu_upload_faktur.dart';
import '../auth/login_screen.dart';
import '../shared/orders_screen.dart';
import 'listing_detail_screen.dart';
import 'upload_invoice_screen.dart';

// Tab Dasbor (penjual): header usaha, 4 angka ringkasan, tombol upload faktur,
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
          appBar: AppBar(title: const Text('Semua pesanan masuk')),
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
      MaterialPageRoute(builder: (context) => const UploadInvoiceScreen()),
    );
    if (!mounted) return;
    await _muatUlang();
  }

  void _bukaDetailStok(int idListing) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SellerListingDetailScreen(idListing: idListing)),
    ).then((_) => _muatUlang());
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
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakTepi),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: AppTheme.rasioKotakRingkasan,
                      mainAxisSpacing: AppTheme.jarakKecil,
                      crossAxisSpacing: AppTheme.jarakKecil,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        KartuAngka(label: 'Lelang aktif', nilai: '$stokAktif', onTap: widget.onPindahKeStok),
                        KartuAngka(
                          label: 'Perlu diproses',
                          nilai: '${perluDiproses.length}',
                          warnaNilai: AppTheme.warnaAksen,
                          onTap: _bukaSemuaPesanan,
                        ),
                        KartuAngka(
                          label: 'Transaksi bulan ini',
                          nilai: '$transaksiBulanIni',
                          warnaNilai: AppTheme.warnaUtama,
                        ),
                        KartuAngka(
                          label: 'Segera kedaluwarsa',
                          nilai: '${segeraKedaluwarsa.length}',
                          warnaNilai: AppTheme.warnaSisaHari,
                          keterangan: 'sisa 14 hari atau kurang',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.jarakKecil),
                    KartuUploadFaktur(onTap: _bukaUploadStok),
                    JudulBagian(
                      judul: 'Perlu disiapkan (${perluDiproses.length})',
                      teksTautan: 'Lihat semua',
                      onTautan: _bukaSemuaPesanan,
                    ),
                    if (perluDiproses.isEmpty)
                      const EmptyState(ikon: Icons.task_alt_rounded, pesan: 'Semua pesanan sudah diproses.')
                    else
                      ...perluDiproses.map(
                        (pesanan) => KartuPesanan(pesanan: pesanan, isPenjual: true, onKembali: _muatUlang),
                      ),
                    if (segeraKedaluwarsa.isNotEmpty) ...[
                      JudulBagian(
                        judul: 'Segera kedaluwarsa (${segeraKedaluwarsa.length})',
                        teksTautan: 'Kelola stok',
                        onTautan: widget.onPindahKeStok,
                      ),
                      ...segeraKedaluwarsa.take(3).map(
                            (listing) => KartuStokKedaluwarsa(
                              listing: listing,
                              onTap: () => _bukaDetailStok(listing.id),
                            ),
                          ),
                    ],
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
