import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../models/order_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/buyer/order_detail_screen.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'dialog_memuat.dart';
import 'status_badge.dart';

// Kartu satu pesanan untuk Pembeli (T3) dan Penjual (T4).
// - Pembeli: info faktur ringkas, status, alamat gudang saat siap diambil.
// - Penjual: tombol aksi cepat langsung di kartu (Siapkan barang, Konfirmasi ambil, Ingatkan pembeli).
class KartuPesanan extends StatelessWidget {
  final OrderModel pesanan;
  final bool isPenjual;
  final VoidCallback? onKembali;

  const KartuPesanan({
    super.key,
    required this.pesanan,
    required this.isPenjual,
    this.onKembali,
  });

  Future<void> _bukaDetail(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(
          idPesanan: pesanan.id,
          isPenjual: isPenjual,
        ),
      ),
    );
    onKembali?.call();
  }

  Future<void> _ubahStatus(BuildContext context, String statusBaru) async {
    tampilkanDialogMemuat(context, pesan: 'Memperbarui status...');
    try {
      await ApiService.ubahStatusPesanan(pesanan.id, statusBaru);
      if (!context.mounted) return;
      Navigator.pop(context); // tutup dialog loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status pesanan berhasil diperbarui')),
      );
      onKembali?.call();
    } catch (e) {
      if (!context.mounted) return;
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

  Future<void> _ingatkanPembeli(BuildContext context) async {
    tampilkanDialogMemuat(context, pesan: 'Mengirim pengingat ke pembeli...');
    try {
      await ApiService.ingatkanPembeli(pesanan.id);
      if (!context.mounted) return;
      Navigator.pop(context); // tutup dialog loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengingat pick-up berhasil dikirim ke pembeli!'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // tutup dialog loading
      final String pesan = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: AppTheme.warnaGalat,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? pihakLain =
        isPenjual ? pesanan.namaPembeli : pesanan.namaPenjual;
    final bool siapDiambil =
        pesanan.status == 'in_progress' && pesanan.alamatGudang != null;

    return Card(
      color: AppTheme.warnaPermukaan,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      margin: const EdgeInsets.only(bottom: AppTheme.jarakKecil),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: () => _bukaDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.jarakSedang),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GambarPesanan(urlGambar: pesanan.urlGambar),
                  const SizedBox(width: AppTheme.jarakSedang),
                  Expanded(child: _buatInfo(pihakLain)),
                ],
              ),
              if (siapDiambil) ...[
                const Divider(height: AppTheme.jarakSedang),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: AppTheme.fontSubjudul,
                      color: AppTheme.warnaUtama,
                    ),
                    const SizedBox(width: AppTheme.jarakKecil / 2),
                    Expanded(
                      child: Text(
                        'Ambil di: ${pesanan.alamatGudang}',
                        style: const TextStyle(
                          fontSize: AppTheme.fontKecil,
                          color: AppTheme.warnaTeks,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              // Tombol aksi penjual langsung di kartu (T4)
              if (isPenjual && pesanan.status != 'completed') ...[
                const SizedBox(height: AppTheme.jarakKecil),
                _buatAksiPenjual(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buatAksiPenjual(BuildContext context) {
    if (pesanan.status == 'paid') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.warnaUtama,
            side: const BorderSide(color: AppTheme.warnaUtama),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
          ),
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Siapkan & Tandai Siap Diambil'),
          onPressed: () => _ubahStatus(context, 'in_progress'),
        ),
      );
    }

    if (pesanan.status == 'in_progress') {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warnaUtama,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                ),
              ),
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Konfirmasi Selesai Diambil'),
              onPressed: () => _ubahStatus(context, 'completed'),
            ),
          ),
          const SizedBox(width: AppTheme.jarakKecil),
          IconButton.outlined(
            tooltip: 'Ingatkan Pembeli untuk Ambil',
            style: IconButton.styleFrom(
              side: const BorderSide(color: AppTheme.warnaAksen),
              foregroundColor: AppTheme.warnaAksen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
            ),
            icon: const Icon(Icons.notifications_active_outlined, size: 20),
            onPressed: () => _ingatkanPembeli(context),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buatInfo(String? pihakLain) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                pesanan.namaProduk,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppTheme.fontNormal,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.jarakKecil),
            StatusBadge(status: pesanan.status, label: pesanan.labelStatus),
          ],
        ),
        const SizedBox(height: AppTheme.jarakKecil / 2),
        Text(
          '${pihakLain == null ? '' : '$pihakLain • '}'
          '${ListingModel.formatTanggal(pesanan.dibuatPada)}',
          style: const TextStyle(
            fontSize: AppTheme.fontKecil,
            color: AppTheme.warnaTeksRedup,
          ),
        ),
        Text(
          '${pesanan.jumlah} x ${ListingModel.formatRupiah(pesanan.hargaSatuan)}',
          style: const TextStyle(
            fontSize: AppTheme.fontKecil,
            color: AppTheme.warnaTeksRedup,
          ),
        ),
        const SizedBox(height: AppTheme.jarakKecil / 2),
        const Text(
          'Total tagihan',
          style: TextStyle(
            fontSize: AppTheme.fontKecil,
            color: AppTheme.warnaTeksRedup,
          ),
        ),
        Text(
          ListingModel.formatRupiah(pesanan.totalHarga),
          style: AppTheme.gayaHarga,
        ),
      ],
    );
  }
}

class _GambarPesanan extends StatelessWidget {
  final String? urlGambar;

  const _GambarPesanan({required this.urlGambar});

  @override
  Widget build(BuildContext context) {
    final Widget gambarCadangan = Container(
      color: AppTheme.warnaGaris,
      child: const Icon(
        Icons.inventory_2_outlined,
        color: AppTheme.warnaTeksRedup,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.jarakKecil),
      child: SizedBox(
        width: AppTheme.gambarKartu,
        height: AppTheme.gambarKartu,
        child: (urlGambar == null || urlGambar!.isEmpty)
            ? gambarCadangan
            : Image.network(
                urlGambar!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => gambarCadangan,
              ),
      ),
    );
  }
}
