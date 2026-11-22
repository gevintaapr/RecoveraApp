import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../services/local_db_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/kartu_pesanan.dart';
import '../../widgets/label_data_offline.dart';
import '../../widgets/ringkasan_pesanan_penjual.dart';
import '../../widgets/tab_segmen.dart';
import '../auth/login_screen.dart';

// Tab Pesanan untuk Pembeli (T3) dan Penjual (T4).
// - Pembeli: Riwayat Transaksi + filter chip status.
// - Penjual: Kelola Pesanan Masuk + kotak ringkasan metrik + aksi langsung.
// Data: _ambilPesanan() -> ApiService.ambilDaftarPesanan() lewat FutureBuilder.
//   Berhasil -> disimpan ke Hive 'orders_cache' (LocalDbService.simpanCachePesanan).
//   Gagal (server mati / offline) -> tampilkan cache Hive + label "Data offline".
class OrdersScreen extends StatefulWidget {
  final bool isPenjual;

  const OrdersScreen({super.key, required this.isPenjual});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<OrderModel>> _futurePesanan;
  String? _filterStatus; // null = Semua
  bool _dataOffline = false; // true = yang tampil adalah cache Hive

  static const Map<String?, String> _labelStatus = {
    null: 'Semua',
    'paid': 'Menunggu',
    'in_progress': 'Siap ambil',
    'completed': 'Selesai',
  };

  @override
  void initState() {
    super.initState();
    _futurePesanan = _ambilPesanan();
  }

  // Ambil dari server lalu simpan ke cache. Bila gagal, pakai cache Hive.
  // "Sesi berakhir" tidak memakai cache: pengguna harus masuk lagi.
  Future<List<OrderModel>> _ambilPesanan() async {
    try {
      final List<OrderModel> daftarPesanan = await ApiService.ambilDaftarPesanan();
      await LocalDbService.simpanCachePesanan(daftarPesanan);
      _dataOffline = false;
      return daftarPesanan;
    } catch (e) {
      final String pesan = e.toString().replaceFirst('Exception: ', '');
      final List<OrderModel> cache = LocalDbService.ambilCachePesanan();
      if (pesan == 'Sesi berakhir' || cache.isEmpty) rethrow;
      _dataOffline = true;
      return cache;
    }
  }

  Future<void> _muatUlang() async {
    final Future<List<OrderModel>> permintaanBaru = _ambilPesanan();
    setState(() {
      _futurePesanan = permintaanBaru;
    });
    try {
      await permintaanBaru;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderModel>>(
      future: _futurePesanan,
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

        final List<OrderModel> semuaPesanan = snapshot.data ?? [];
        final List<OrderModel> daftarPesanan = _filterStatus == null
            ? semuaPesanan
            : semuaPesanan
                .where((pesanan) => pesanan.status == _filterStatus)
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Layar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.jarakSedang,
                AppTheme.jarakSedang,
                AppTheme.jarakSedang,
                AppTheme.jarakKecil,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isPenjual ? 'Pesanan masuk' : 'Riwayat transaksi',
                    style: const TextStyle(
                      fontSize: AppTheme.fontSubjudul,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.warnaNavy,
                    ),
                  ),
                  const Text(
                    'Tarik ke bawah untuk memperbarui',
                    style: TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup),
                  ),
                ],
              ),
            ),

            if (_dataOffline) const LabelDataOffline(),

            // Kotak Ringkasan Khusus Penjual (T4)
            if (widget.isPenjual) ...[
              RingkasanPesananPenjual(daftarPesanan: semuaPesanan),
              const SizedBox(height: AppTheme.jarakKecil),
            ],

            // Chip Status Horizontal dengan Jumlah
            _buatChipStatus(semuaPesanan),

            const SizedBox(height: AppTheme.jarakKecil),

            // Daftar Pesanan
            Expanded(
              child: RefreshIndicator(
                onRefresh: _muatUlang,
                child: daftarPesanan.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: AppTheme.jarakBesar),
                          EmptyState(
                            ikon: Icons.receipt_long_outlined,
                            pesan: _pesanKosong(semuaPesanan.isEmpty),
                          ),
                        ],
                      )
                    : ListView.builder(
                        // Jarak bawah ikut tinggi bar navigasi kaca (extendBody).
                        padding: EdgeInsets.fromLTRB(
                          AppTheme.jarakSedang,
                          AppTheme.jarakKecil / 2,
                          AppTheme.jarakSedang,
                          MediaQuery.paddingOf(context).bottom + AppTheme.jarakSedang,
                        ),
                        itemCount: daftarPesanan.length,
                        itemBuilder: (context, indeks) => KartuPesanan(
                          pesanan: daftarPesanan[indeks],
                          isPenjual: widget.isPenjual,
                          onKembali: _muatUlang,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Tab segmen status + jumlahnya; menyaring daftar di HP (setState).
  Widget _buatChipStatus(List<OrderModel> semuaPesanan) {
    final List<String?> daftarKunci = _labelStatus.keys.toList();
    final List<String> daftarLabel = daftarKunci.map((kunci) {
      final int jumlah = kunci == null
          ? semuaPesanan.length
          : semuaPesanan.where((o) => o.status == kunci).length;
      return '${_labelStatus[kunci]} $jumlah';
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang),
      child: TabSegmen(
        daftarLabel: daftarLabel,
        indeksAktif: daftarKunci.indexOf(_filterStatus),
        onPilih: (indeks) => setState(() => _filterStatus = daftarKunci[indeks]),
      ),
    );
  }

  String _pesanKosong(bool belumAdaSamaSekali) {
    if (!belumAdaSamaSekali) return 'Tidak ada pesanan dengan status ini';
    return widget.isPenjual ? 'Belum ada pesanan masuk' : 'Belum ada pembelian';
  }
}
