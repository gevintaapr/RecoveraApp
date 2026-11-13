import 'package:flutter/material.dart';

import '../../models/listing_model.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';

// Detail satu pesanan. idPesanan dikirim lewat konstruktor
// (dari daftar pesanan, atau langsung setelah Beli Sekarang berhasil).
// Data: ApiService.ambilDetailPesanan(idPesanan) lewat FutureBuilder.
class OrderDetailScreen extends StatefulWidget {
  final int idPesanan;

  const OrderDetailScreen({super.key, required this.idPesanan});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<OrderModel> _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = ApiService.ambilDetailPesanan(widget.idPesanan);
  }

  Future<void> _muatUlang() async {
    final Future<OrderModel> permintaanBaru = ApiService.ambilDetailPesanan(widget.idPesanan);
    setState(() {
      _futureDetail = permintaanBaru;
    });
    try {
      await permintaanBaru;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pesanan #${widget.idPesanan}')),
      body: FutureBuilder<OrderModel>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return EmptyState(
              ikon: Icons.error_outline,
              pesan: snapshot.error.toString().replaceFirst('Exception: ', ''),
              teksTombol: 'Coba lagi',
              onTombolDitekan: _muatUlang,
            );
          }
          final OrderModel pesanan = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _muatUlang,
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.jarakSedang),
              children: [
                Text(pesanan.namaProduk, style: AppTheme.gayaJudul),
                const SizedBox(height: AppTheme.jarakKecil),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge(status: pesanan.status, label: pesanan.labelStatus),
                ),
                const Divider(height: AppTheme.jarakBesar * 2),
                _BarisInfo(label: 'Jumlah', nilai: '${pesanan.jumlah}'),
                _BarisInfo(label: 'Harga satuan', nilai: ListingModel.formatRupiah(pesanan.hargaSatuan)),
                _BarisInfo(label: 'Total', nilai: ListingModel.formatRupiah(pesanan.totalHarga)),
                _BarisInfo(label: 'Tanggal', nilai: '${ListingModel.formatTanggal(pesanan.dibuatPada)}, ${ListingModel.formatJam(pesanan.dibuatPada)}'),
                _BarisInfo(label: 'Penjual', nilai: pesanan.namaPenjual ?? '-'),
                _BarisInfo(label: 'Ambil di', nilai: pesanan.alamatGudang ?? '-'),
                const SizedBox(height: AppTheme.jarakBesar),
                Text(_keteranganStatus(pesanan.status), style: AppTheme.gayaTeksRedup),
              ],
            ),
          );
        },
      ),
    );
  }

  String _keteranganStatus(String status) {
    switch (status) {
      case 'paid':
        return 'Penjual sedang menyiapkan pesanan. Tarik ke bawah untuk memperbarui status.';
      case 'in_progress':
        return 'Pesanan siap diambil di gudang penjual.';
      default:
        return 'Pesanan sudah selesai.';
    }
  }
}

class _BarisInfo extends StatelessWidget {
  final String label;
  final String nilai;

  const _BarisInfo({required this.label, required this.nilai});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.jarakKecil / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: AppTheme.gayaTeksRedup)),
          Expanded(flex: 3, child: Text(nilai)),
        ],
      ),
    );
  }
}
