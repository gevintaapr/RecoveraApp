import 'package:flutter/material.dart';

import '../../models/listing_model.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/tombol_kembali.dart';
import '../../widgets/baris_info.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';
import '../auth/login_screen.dart';

// Detail satu pesanan (T3 & T4).
// Menampilkan Rincian Faktur B2B, info pengambilan gudang,
// tombol "Ingatkan Penjual" untuk pembeli saat status 'paid',
// dan tombol aksi pembaruan status bagi penjual.
class OrderDetailScreen extends StatefulWidget {
  final int idPesanan;
  final bool isPenjual;

  const OrderDetailScreen({
    super.key,
    required this.idPesanan,
    this.isPenjual = false,
  });

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
    final Future<OrderModel> permintaanBaru = ApiService.ambilDetailPesanan(
      widget.idPesanan,
    );
    setState(() {
      _futureDetail = permintaanBaru;
    });
    try {
      await permintaanBaru;
    } catch (_) {}
  }

  Future<void> _ingatkanPenjual() async {
    tampilkanDialogMemuat(context, pesan: 'Mengirim pengingat ke penjual...');
    try {
      await ApiService.ingatkanPenjual(widget.idPesanan);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengingat telah dikirim ke penjual!')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      final String pesan = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesan), backgroundColor: AppTheme.warnaGalat),
      );
    }
  }

  Future<void> _ubahStatus(String statusSekarang) async {
    tampilkanDialogMemuat(context, pesan: 'Memperbarui status...');
    try {
      await ApiService.ubahStatusPesanan(
        widget.idPesanan,
        _statusBerikutnya(statusSekarang)!,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status pesanan diperbarui')),
      );
      await _muatUlang();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      final String pesan = e.toString().replaceFirst('Exception: ', '');
      if (pesan == 'Sesi berakhir') {
        await kembaliKeLogin(context);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesan), backgroundColor: AppTheme.warnaGalat),
      );
    }
  }

  String? _statusBerikutnya(String status) {
    if (status == 'paid') return 'in_progress';
    if (status == 'in_progress') return 'completed';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const TombolKembali(), // selalu tampil, juga saat dibuka dari notifikasi
        title: Text('Pesanan #${widget.idPesanan}'),
      ),
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
                  child: StatusBadge(
                    status: pesanan.status,
                    label: pesanan.labelStatus,
                  ),
                ),
                const SizedBox(height: AppTheme.jarakSedang),
                _RincianFaktur(pesanan: pesanan),
                const SizedBox(height: AppTheme.jarakSedang),
                BarisInfo(
                  label: 'Tanggal',
                  nilai:
                      '${ListingModel.formatTanggal(pesanan.dibuatPada)}, ${ListingModel.formatJam(pesanan.dibuatPada)}',
                ),
                if (widget.isPenjual)
                  BarisInfo(label: 'Pembeli', nilai: pesanan.namaPembeli ?? '-')
                else
                  BarisInfo(
                    label: 'Penjual',
                    nilai: pesanan.namaPenjual ?? '-',
                  ),
                BarisInfo(
                  label: 'Ambil di',
                  nilai: pesanan.alamatGudang ?? '-',
                ),
                const SizedBox(height: AppTheme.jarakBesar),

                // Tombol Aksi
                if (widget.isPenjual &&
                    _statusBerikutnya(pesanan.status) != null) ...[
                  PrimaryButton(
                    teks: pesanan.status == 'paid'
                        ? 'Tandai siap diambil'
                        : 'Konfirmasi telah diambil',
                    onPressed: () => _ubahStatus(pesanan.status),
                  ),
                ] else if (!widget.isPenjual && pesanan.status == 'paid') ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.warnaUtama,
                      side: const BorderSide(color: AppTheme.warnaUtama),
                      minimumSize: const Size.fromHeight(AppTheme.tinggiTombol),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                      ),
                    ),
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: const Text('Ingatkan Penjual Siapkan Pesanan'),
                    onPressed: _ingatkanPenjual,
                  ),
                ] else ...[
                  Text(
                    _keteranganStatus(pesanan.status),
                    style: AppTheme.gayaTeksRedup,
                  ),
                ],
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

class _RincianFaktur extends StatelessWidget {
  final OrderModel pesanan;

  const _RincianFaktur({required this.pesanan});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.warnaPermukaan,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: const BorderSide(color: AppTheme.warnaGaris),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.jarakSedang),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt_long_outlined, color: AppTheme.warnaUtama),
                SizedBox(width: AppTheme.jarakKecil),
                Text('Rincian Faktur B2B', style: AppTheme.gayaSubjudul),
              ],
            ),
            const Divider(height: AppTheme.jarakBesar),
            BarisInfo(label: 'Nomor pesanan', nilai: '#${pesanan.id}'),
            BarisInfo(label: 'Produk', nilai: pesanan.namaProduk),
            BarisInfo(label: 'Jumlah', nilai: '${pesanan.jumlah}'),
            BarisInfo(
              label: 'Harga satuan final',
              nilai: ListingModel.formatRupiah(pesanan.hargaSatuan),
            ),
            BarisInfo(
              label: 'Biaya platform',
              nilai: ListingModel.formatRupiah(0),
            ),
            const Divider(height: AppTheme.jarakBesar),
            Row(
              children: [
                const Expanded(
                  child: Text('Total tagihan', style: AppTheme.gayaSubjudul),
                ),
                Text(
                  ListingModel.formatRupiah(pesanan.totalHarga),
                  style: AppTheme.gayaHarga,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
