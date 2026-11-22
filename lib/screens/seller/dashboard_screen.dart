import 'package:flutter/material.dart';

import '../../models/listing_model.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/kartu_pesanan.dart';
import '../auth/login_screen.dart';
import '../shared/orders_screen.dart';

// Tab Dasbor (penjual): ringkasan + pesanan yang perlu diproses.
// Data: ApiService.ambilInventaris() dan ApiService.ambilDaftarPesanan(),
// digabung dalam satu Future lalu ditampilkan oleh FutureBuilder.
// Ringkasan memakai GridView (Modul II). Ketuk pesanan -> detail pesanan
// (ubah status); setelah kembali, dasbor dimuat ulang (setState).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// Wadah dua hasil request agar cukup satu FutureBuilder.
class _DataDasbor {
  final List<ListingModel> daftarStok;
  final List<OrderModel> daftarPesanan;

  _DataDasbor({required this.daftarStok, required this.daftarPesanan});
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<_DataDasbor> _futureDasbor;

  @override
  void initState() {
    super.initState();
    _futureDasbor = _ambilDataDasbor();
  }

  Future<_DataDasbor> _ambilDataDasbor() async {
    final List<ListingModel> stok = await ApiService.ambilInventaris();
    final List<OrderModel> pesanan = await ApiService.ambilDaftarPesanan();
    return _DataDasbor(daftarStok: stok, daftarPesanan: pesanan);
  }

  Future<void> _muatUlang() async {
    final Future<_DataDasbor> permintaanBaru = _ambilDataDasbor();
    setState(() {
      _futureDasbor = permintaanBaru;
    });
    try {
      await permintaanBaru;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  Future<void> _bukaSemuaPesanan() async {
    // OrdersScreen dipakai ulang (juga tab Pesanan pembeli), dibungkus Scaffold.
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
        final List<OrderModel> perluDiproses =
            data.daftarPesanan.where((p) => p.status != 'completed').toList();
        final int jumlahAktif = data.daftarStok.where((l) => l.status == 'active').length;
        final int jumlahDraft = data.daftarStok.where((l) => l.masihDraft).length;
        final int jumlahSelesai = data.daftarPesanan.where((p) => p.status == 'completed').length;

        return RefreshIndicator(
          onRefresh: _muatUlang,
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.jarakSedang),
            children: [
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: AppTheme.rasioKotakRingkasan,
                mainAxisSpacing: AppTheme.jarakKecil,
                crossAxisSpacing: AppTheme.jarakKecil,
                // Grid di dalam ListView: ikut tinggi isinya, tidak menggulir sendiri.
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _KotakRingkasan(ikon: Icons.storefront_outlined, angka: jumlahAktif, label: 'Listing aktif'),
                  _KotakRingkasan(ikon: Icons.edit_note, angka: jumlahDraft, label: 'Draft'),
                  _KotakRingkasan(ikon: Icons.pending_actions, angka: perluDiproses.length, label: 'Perlu diproses'),
                  _KotakRingkasan(ikon: Icons.task_alt, angka: jumlahSelesai, label: 'Pesanan selesai'),
                ],
              ),
              const SizedBox(height: AppTheme.jarakBesar),
              Row(
                children: [
                  const Expanded(child: Text('Pesanan perlu diproses', style: AppTheme.gayaSubjudul)),
                  TextButton(onPressed: _bukaSemuaPesanan, child: const Text('Lihat semua')),
                ],
              ),
              if (perluDiproses.isEmpty)
                const EmptyState(ikon: Icons.inbox_outlined, pesan: 'Tidak ada pesanan yang menunggu.')
              else
                ...perluDiproses.map((pesanan) => KartuPesanan(
                      pesanan: pesanan,
                      isPenjual: true,
                      onKembali: _muatUlang,
                    )),
            ],
          ),
        );
      },
    );
  }
}

class _KotakRingkasan extends StatelessWidget {
  final IconData ikon;
  final int angka;
  final String label;

  const _KotakRingkasan({required this.ikon, required this.angka, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.warnaPermukaan,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.jarakSedang),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: AppTheme.warnaUtama),
            const SizedBox(height: AppTheme.jarakKecil / 2),
            Text('$angka', style: AppTheme.gayaJudul),
            Text(label, style: AppTheme.gayaTeksRedup),
          ],
        ),
      ),
    );
  }
}
