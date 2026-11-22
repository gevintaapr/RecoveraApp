import 'package:flutter/material.dart';

import '../../models/listing_model.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bar_aksi_cepat.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/kartu_pesanan.dart';
import '../../widgets/kartu_stok_kedaluwarsa.dart';
import '../auth/login_screen.dart';
import '../shared/orders_screen.dart';
import 'listing_detail_screen.dart';
import 'upload_invoice_screen.dart';

// Tab Dasbor (penjual): profil usaha, aksi cepat, ringkasan metrik,
// stok mendekati kedaluwarsa, dan pesanan yang menunggu tindakan (T5).
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

  _DataDasbor({
    required this.profil,
    required this.daftarStok,
    required this.daftarPesanan,
  });
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
    return _DataDasbor(
      profil: profil,
      daftarStok: stok,
      daftarPesanan: pesanan,
    );
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
          appBar: AppBar(title: const Text('Semua Pesanan Masuk')),
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
      MaterialPageRoute(
        builder: (context) => const UploadInvoiceScreen(),
      ),
    );
    if (!mounted) return;
    await _muatUlang();
  }

  void _bukaDetailStok(int idListing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellerListingDetailScreen(idListing: idListing),
      ),
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
          final String pesan =
              snapshot.error.toString().replaceFirst('Exception: ', '');
          final bool sesiBerakhir = pesan == 'Sesi berakhir';
          return EmptyState(
            ikon: sesiBerakhir ? Icons.lock_outline : Icons.wifi_off,
            pesan: sesiBerakhir ? 'Sesi berakhir, silakan masuk lagi.' : pesan,
            teksTombol: sesiBerakhir ? 'Masuk lagi' : 'Coba lagi',
            onTombolDitekan:
                sesiBerakhir ? () => kembaliKeLogin(context) : _muatUlang,
          );
        }

        final _DataDasbor data = snapshot.data!;
        final DateTime now = DateTime.now();

        // 1. Perhitungan Metrik
        final int stokAktif =
            data.daftarStok.where((l) => l.status == 'active').length;
        final int transaksiBulanIni = data.daftarPesanan
            .where((p) =>
                p.dibuatPada.year == now.year &&
                p.dibuatPada.month == now.month)
            .length;
        final List<ListingModel> daftarMendekatiKedaluwarsa = data.daftarStok
            .where((l) =>
                l.status == 'active' &&
                l.sisaHari != null &&
                l.sisaHari! <= 14)
            .toList();
        final List<OrderModel> perluDiproses = data.daftarPesanan
            .where((p) => p.status != 'completed')
            .toList();

        return RefreshIndicator(
          onRefresh: _muatUlang,
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.jarakSedang),
            children: [
              // Header Profil Penjual
              _buildHeaderPenjual(data.profil),
              const SizedBox(height: AppTheme.jarakSedang),

              // Bar Aksi Cepat (Upload, Inventaris, Pesanan)
              BarAksiCepat(
                onUploadStok: _bukaUploadStok,
                onBukaStok: () => widget.onPindahKeStok?.call(),
                onBukaPesanan: _bukaSemuaPesanan,
              ),
              const SizedBox(height: AppTheme.jarakSedang),

              // Grid Kotak Ringkasan 2x2
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: AppTheme.rasioKotakRingkasan,
                mainAxisSpacing: AppTheme.jarakKecil,
                crossAxisSpacing: AppTheme.jarakKecil,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _KotakRingkasan(
                    ikon: Icons.storefront_outlined,
                    angka: stokAktif,
                    label: 'Stok aktif',
                    warnaIkon: AppTheme.warnaUtama,
                  ),
                  _KotakRingkasan(
                    ikon: Icons.trending_up_rounded,
                    angka: transaksiBulanIni,
                    label: 'Transaksi bulan ini',
                    warnaIkon: AppTheme.warnaUtama,
                  ),
                  _KotakRingkasan(
                    ikon: Icons.warning_amber_rounded,
                    angka: daftarMendekatiKedaluwarsa.length,
                    label: 'Segera kedaluwarsa',
                    warnaIkon: AppTheme.warnaAksen,
                  ),
                  _KotakRingkasan(
                    ikon: Icons.pending_actions_rounded,
                    angka: perluDiproses.length,
                    label: 'Perlu diproses',
                    warnaIkon: AppTheme.warnaAksen,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.jarakBesar),

              // Bagian: Stok Mendekati Kedaluwarsa (<= 14 hari)
              if (daftarMendekatiKedaluwarsa.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: AppTheme.warnaAksen,
                    ),
                    const SizedBox(width: AppTheme.jarakKecil),
                    Expanded(
                      child: Text(
                        'Stok Mendekati Kedaluwarsa (${daftarMendekatiKedaluwarsa.length})',
                        style: AppTheme.gayaSubjudul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.jarakKecil),
                ...daftarMendekatiKedaluwarsa.take(3).map(
                      (listing) => KartuStokKedaluwarsa(
                        listing: listing,
                        onTap: () => _bukaDetailStok(listing.id),
                      ),
                    ),
                const SizedBox(height: AppTheme.jarakBesar),
              ],

              // Bagian: Pesanan Menunggu Tindakan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Pesanan Menunggu Tindakan (${perluDiproses.length})',
                      style: AppTheme.gayaSubjudul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: _bukaSemuaPesanan,
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.jarakKecil / 2),
              if (perluDiproses.isEmpty)
                const EmptyState(
                  ikon: Icons.task_alt_rounded,
                  pesan: 'Semua pesanan pelanggan telah diproses.',
                )
              else
                ...perluDiproses.map(
                  (pesanan) => KartuPesanan(
                    pesanan: pesanan,
                    isPenjual: true,
                    onKembali: _muatUlang,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderPenjual(UserModel profil) {
    final String namaBadanUsaha = profil.namaPerusahaan?.isNotEmpty == true
        ? profil.namaPerusahaan!
        : (profil.nama.isNotEmpty ? profil.nama : 'Distributor Resmi');
    final String kotaGudang =
        profil.kota?.isNotEmpty == true ? profil.kota! : 'Gudang Utama';

    return Container(
      padding: const EdgeInsets.all(AppTheme.jarakSedang),
      decoration: BoxDecoration(
        color: AppTheme.warnaUtama.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.warnaUtama.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.warnaUtama,
            child: const Icon(Icons.business_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppTheme.jarakSedang),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaBadanUsaha,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warnaTeks,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppTheme.warnaUtama,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      kotaGudang,
                      style: const TextStyle(
                        fontSize: AppTheme.fontKecil,
                        color: AppTheme.warnaTeksRedup,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warnaUtama.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                      ),
                      child: const Text(
                        'Verified Seller',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warnaUtama,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KotakRingkasan extends StatelessWidget {
  final IconData ikon;
  final int angka;
  final String label;
  final Color warnaIkon;

  const _KotakRingkasan({
    required this.ikon,
    required this.angka,
    required this.label,
    required this.warnaIkon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.warnaPermukaan,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: const BorderSide(color: AppTheme.warnaGaris),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.jarakSedang),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: warnaIkon, size: 24),
            const SizedBox(height: AppTheme.jarakKecil / 2),
            Text('$angka', style: AppTheme.gayaJudul),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontKecil,
                color: AppTheme.warnaTeksRedup,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
