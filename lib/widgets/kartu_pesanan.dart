import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../models/order_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/buyer/order_detail_screen.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'dialog_memuat.dart';
import 'primary_button.dart';
import 'status_badge.dart';

// Kartu satu pesanan untuk Pembeli (T3) dan Penjual (T4):
// nomor + tanggal + status, produk + total, nama pihak lain, lokasi ambil.
// Penjual: tombol aksi langsung di kartu (Tandai siap diambil, Konfirmasi
// sudah diambil, Ingatkan pembeli).
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
        SnackBar(content: Text(pesan), backgroundColor: AppTheme.warnaGalat),
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
        const SnackBar(content: Text('Pengingat pick-up berhasil dikirim ke pembeli')),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // tutup dialog loading
      final String pesan = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesan), backgroundColor: AppTheme.warnaGalat),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? pihakLain = isPenjual ? pesanan.namaPembeli : pesanan.namaPenjual;
    final bool siapDiambil = pesanan.status == 'in_progress' && pesanan.alamatGudang != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.jarakKecil),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: () => _bukaDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.jarakSedang),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PESANAN #${pesanan.id} · ${ListingModel.formatTanggal(pesanan.dibuatPada)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.gayaLabelKapital,
                      ),
                    ),
                    StatusBadge(status: pesanan.status, label: pesanan.labelStatus),
                  ],
                ),
                const SizedBox(height: AppTheme.jarakKecil),
                Row(
                  children: [
                    _GambarPesanan(urlGambar: pesanan.urlGambar),
                    const SizedBox(width: AppTheme.jarakSedang),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pesanan.namaProduk,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${pesanan.jumlah} × ${ListingModel.formatRupiah(pesanan.hargaSatuan)}',
                            style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup),
                          ),
                        ],
                      ),
                    ),
                    Text(ListingModel.formatRupiah(pesanan.totalHarga), style: AppTheme.gayaHarga),
                  ],
                ),
                if (pihakLain != null) ...[
                  const SizedBox(height: AppTheme.jarakKecil),
                  _PanelPihakLain(nama: pihakLain, sebagaiPembeli: isPenjual),
                ],
                if (siapDiambil) ...[
                  const SizedBox(height: AppTheme.jarakKecil),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: AppTheme.ikonKecil, color: AppTheme.warnaUtama),
                      const SizedBox(width: AppTheme.jarakMini),
                      Expanded(
                        child: Text(
                          'Ambil di: ${pesanan.alamatGudang}',
                          style: const TextStyle(fontSize: AppTheme.fontKecil),
                        ),
                      ),
                    ],
                  ),
                ],
                // Tombol aksi penjual langsung di kartu (T4).
                if (isPenjual && pesanan.status != 'completed') ...[
                  const SizedBox(height: AppTheme.jarakKecil),
                  _buatAksiPenjual(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buatAksiPenjual(BuildContext context) {
    if (pesanan.status == 'paid') {
      return PrimaryButton(
        teks: 'Tandai siap diambil',
        ikon: Icons.check_circle_outline,
        onPressed: () => _ubahStatus(context, 'in_progress'),
      );
    }
    if (pesanan.status == 'in_progress') {
      return Row(
        children: [
          Expanded(
            child: PrimaryButton(
              teks: 'Konfirmasi sudah diambil',
              ikon: Icons.done_all_rounded,
              onPressed: () => _ubahStatus(context, 'completed'),
            ),
          ),
          const SizedBox(width: AppTheme.jarakKecil),
          IconButton.outlined(
            tooltip: 'Ingatkan pembeli untuk mengambil',
            constraints: const BoxConstraints(
              minWidth: AppTheme.tinggiTombol,
              minHeight: AppTheme.tinggiTombol,
            ),
            style: IconButton.styleFrom(
              foregroundColor: AppTheme.warnaAksen,
              side: const BorderSide(color: AppTheme.warnaGarisTegas),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusTombol)),
            ),
            icon: const Icon(Icons.notifications_active_outlined, size: AppTheme.ikonSedang),
            onPressed: () => _ingatkanPembeli(context),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

// Kotak kecil: inisial + nama pembeli (dilihat penjual) atau penjual (dilihat pembeli).
class _PanelPihakLain extends StatelessWidget {
  final String nama;
  final bool sebagaiPembeli;

  const _PanelPihakLain({required this.nama, required this.sebagaiPembeli});

  String get _inisial {
    final List<String> kata = nama.trim().split(' ').where((k) => k.isNotEmpty).toList();
    if (kata.isEmpty) return '?';
    return kata.take(2).map((k) => k[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang, vertical: AppTheme.jarakKecil),
      decoration: BoxDecoration(
        color: AppTheme.warnaLatar,
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
      ),
      child: Row(
        children: [
          Container(
            width: AppTheme.ukuranTombolKecil,
            height: AppTheme.ukuranTombolKecil,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppTheme.warnaLatarInfo, shape: BoxShape.circle),
            child: Text(
              _inisial,
              style: const TextStyle(
                fontSize: AppTheme.fontLabel,
                fontWeight: FontWeight.w800,
                color: AppTheme.warnaTeksInfo,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.jarakKecil),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w700),
                ),
                Text(
                  sebagaiPembeli ? 'Pembeli · ambil di gudang' : 'Penjual · ambil di gudang',
                  style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GambarPesanan extends StatelessWidget {
  final String? urlGambar;

  const _GambarPesanan({required this.urlGambar});

  @override
  Widget build(BuildContext context) {
    const Widget gambarCadangan = ColoredBox(
      color: AppTheme.warnaLatarNetral,
      child: Center(
        child: Icon(Icons.inventory_2_outlined, size: AppTheme.ikonSedang, color: AppTheme.warnaTeksRedup),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusTombol),
      child: SizedBox(
        width: AppTheme.ukuranTombolIkon,
        height: AppTheme.ukuranTombolIkon,
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
