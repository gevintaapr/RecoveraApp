import 'package:flutter/material.dart';

import '../../models/listing_model.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/baris_info.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';
import '../auth/login_screen.dart';

// Detail satu pesanan. idPesanan dikirim lewat konstruktor
// (dari daftar pesanan, atau langsung setelah Beli Sekarang berhasil).
// Data: ApiService.ambilDetailPesanan(idPesanan) lewat FutureBuilder.
// Penjual (isPenjual = true) mendapat tombol ubah status:
//   paid -> in_progress ("siap diambil") -> completed ("sudah diambil").
// Tombol -> dialog loading -> ApiService.ubahStatusPesanan -> _muatUlang (setState).
class OrderDetailScreen extends StatefulWidget {
  final int idPesanan;
  final bool isPenjual;

  const OrderDetailScreen({super.key, required this.idPesanan, this.isPenjual = false});

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
                BarisInfo(label: 'Jumlah', nilai: '${pesanan.jumlah}'),
                BarisInfo(label: 'Harga satuan', nilai: ListingModel.formatRupiah(pesanan.hargaSatuan)),
                BarisInfo(label: 'Total', nilai: ListingModel.formatRupiah(pesanan.totalHarga)),
                BarisInfo(label: 'Tanggal', nilai: '${ListingModel.formatTanggal(pesanan.dibuatPada)}, ${ListingModel.formatJam(pesanan.dibuatPada)}'),
                if (widget.isPenjual)
                  BarisInfo(label: 'Pembeli', nilai: pesanan.namaPembeli ?? '-')
                else
                  BarisInfo(label: 'Penjual', nilai: pesanan.namaPenjual ?? '-'),
                BarisInfo(label: 'Ambil di', nilai: pesanan.alamatGudang ?? '-'),
                const SizedBox(height: AppTheme.jarakBesar),
                if (widget.isPenjual && _statusBerikutnya(pesanan.status) != null)
                  PrimaryButton(
                    teks: pesanan.status == 'paid' ? 'Tandai siap diambil' : 'Tandai sudah diambil',
                    onPressed: () => _ubahStatus(pesanan.status),
                  )
                else
                  Text(_keteranganStatus(pesanan.status), style: AppTheme.gayaTeksRedup),
              ],
            ),
          );
        },
      ),
    );
  }

  // Status tujuan sesuai urutan server; null = sudah selesai.
  String? _statusBerikutnya(String status) {
    if (status == 'paid') return 'in_progress';
    if (status == 'in_progress') return 'completed';
    return null;
  }

  Future<void> _ubahStatus(String statusSekarang) async {
    tampilkanDialogMemuat(context, pesan: 'Memperbarui status...');
    try {
      await ApiService.ubahStatusPesanan(widget.idPesanan, _statusBerikutnya(statusSekarang)!);
      if (!mounted) return;
      Navigator.pop(context); // tutup dialog loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status pesanan diperbarui')),
      );
      await _muatUlang();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // tutup dialog loading
      final String pesan = e.toString().replaceFirst('Exception: ', '');
      if (pesan == 'Sesi berakhir') {
        await kembaliKeLogin(context);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: AppTheme.warnaGalat,
        ),
      );
    }
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
