import 'package:flutter/material.dart';

import '../../models/listing_model.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../auth/login_screen.dart';
import '../buyer/order_detail_screen.dart';

// Tab Pesanan. Dipakai kedua peran:
// - pembeli: riwayat pembelian
// - penjual: pesanan masuk (aksi ubah status ditambahkan di langkah penjual)
// Data: ApiService.ambilDaftarPesanan() lewat FutureBuilder.
// setState: saat ditarik ke bawah -> future diganti -> daftar dimuat ulang.
class OrdersScreen extends StatefulWidget {
  final bool isPenjual;

  const OrdersScreen({super.key, required this.isPenjual});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<OrderModel>> _futurePesanan;

  @override
  void initState() {
    super.initState();
    _futurePesanan = ApiService.ambilDaftarPesanan();
  }

  Future<void> _muatUlang() async {
    final Future<List<OrderModel>> permintaanBaru = ApiService.ambilDaftarPesanan();
    setState(() => _futurePesanan = permintaanBaru);
    try {
      await permintaanBaru;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
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
          final String pesan = snapshot.error.toString().replaceFirst('Exception: ', '');
          final bool sesiBerakhir = pesan == 'Sesi berakhir';
          return EmptyState(
            ikon: sesiBerakhir ? Icons.lock_outline : Icons.wifi_off,
            pesan: sesiBerakhir ? 'Sesi berakhir, silakan masuk lagi.' : pesan,
            teksTombol: sesiBerakhir ? 'Masuk lagi' : 'Coba lagi',
            onTombolDitekan: sesiBerakhir ? () => kembaliKeLogin(context) : _muatUlang,
          );
        }
        final List<OrderModel> daftarPesanan = snapshot.data ?? [];
        return RefreshIndicator(
          onRefresh: _muatUlang,
          child: daftarPesanan.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: AppTheme.jarakBesar),
                    EmptyState(
                      ikon: Icons.receipt_long_outlined,
                      pesan: widget.isPenjual ? 'Belum ada pesanan masuk' : 'Belum ada pembelian',
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.jarakSedang),
                  itemCount: daftarPesanan.length,
                  itemBuilder: (context, indeks) =>
                      _KartuPesanan(pesanan: daftarPesanan[indeks], isPenjual: widget.isPenjual),
                ),
        );
      },
    );
  }
}

class _KartuPesanan extends StatelessWidget {
  final OrderModel pesanan;
  final bool isPenjual;

  const _KartuPesanan({required this.pesanan, required this.isPenjual});

  @override
  Widget build(BuildContext context) {
    // Penjual melihat nama pembeli, pembeli melihat nama penjual.
    final String? pihakLain = isPenjual ? pesanan.namaPembeli : pesanan.namaPenjual;

    return Card(
      color: AppTheme.warnaPermukaan,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: ListTile(
        title: Text(pesanan.namaProduk, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${pesanan.jumlah} x ${ListingModel.formatRupiah(pesanan.hargaSatuan)}'
          '${pihakLain == null ? '' : '\n$pihakLain'}\n'
          '${ListingModel.formatTanggal(pesanan.dibuatPada)}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(ListingModel.formatRupiah(pesanan.totalHarga), style: AppTheme.gayaHarga),
            const SizedBox(height: AppTheme.jarakKecil / 2),
            StatusBadge(status: pesanan.status, label: pesanan.labelStatus),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderDetailScreen(idPesanan: pesanan.id)),
        ),
      ),
    );
  }
}
