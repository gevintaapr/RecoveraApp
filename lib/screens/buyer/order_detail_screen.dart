import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar_transaksi.dart';
import '../../widgets/baris_info.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/kartu_bagian.dart';
import '../../widgets/kartu_faktur_pesanan.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';

// Detail satu pesanan (T3 & T4), tampilan faktur Recovera lama.
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
      appBar: const AppBarTransaksi(judul: 'Detail Pesanan'),
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
              padding: const EdgeInsets.all(AppTheme.jarakTepi),
              children: [
                KartuFakturPesanan(pesanan: pesanan),
                const SizedBox(height: AppTheme.jarakSedang),
                KartuBagian(
                  judul: 'Informasi Pengambilan',
                  children: [
                    BarisInfo(
                      label: widget.isPenjual ? 'Pembeli' : 'Penjual',
                      nilai:
                          (widget.isPenjual
                              ? pesanan.namaPembeli
                              : pesanan.namaPenjual) ??
                          '-',
                    ),
                    const BarisInfo(label: 'Metode', nilai: 'Ambil di gudang'),
                    BarisInfo(
                      label: 'Ambil di',
                      nilai: pesanan.alamatGudang ?? '-',
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.jarakBesar),
                // Tombol aksi sesuai peran & status.
                if (widget.isPenjual &&
                    _statusBerikutnya(pesanan.status) != null)
                  PrimaryButton(
                    teks: pesanan.status == 'paid'
                        ? 'Tandai siap diambil'
                        : 'Konfirmasi telah diambil',
                    ikon: pesanan.status == 'paid'
                        ? Icons.check_circle_outline
                        : Icons.done_all_rounded,
                    onPressed: () => _ubahStatus(pesanan.status),
                  )
                else if (!widget.isPenjual && pesanan.status == 'paid')
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppTheme.tinggiTombol),
                      side: const BorderSide(
                        color: AppTheme.warnaUtama,
                        width: 2,
                      ),
                    ),
                    icon: const Icon(
                      Icons.notifications_active_outlined,
                      size: AppTheme.ikonKecil,
                    ),
                    label: const Text('Ingatkan Penjual Siapkan Pesanan'),
                    onPressed: _ingatkanPenjual,
                  )
                else
                  Text(
                    _keteranganStatus(pesanan.status),
                    textAlign: TextAlign.center,
                    style: AppTheme.gayaTeksRedup,
                  ),
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
