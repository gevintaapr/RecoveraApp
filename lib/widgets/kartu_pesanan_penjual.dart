import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

// Tampilan kartu pesanan masuk untuk penjual (_buildSellerOrderCard Recovera lama):
// nama pembeli + status, tanggal & ID, foto + produk + kategori, harga satuan +
// total, lalu tombol aksi sesuai status. Logika aksinya ada di KartuPesanan
// (dikirim lewat callback), widget ini hanya tampilan.
class KartuPesananPenjual extends StatelessWidget {
  final OrderModel pesanan;
  final VoidCallback onBukaDetail;
  final ValueChanged<String> onUbahStatus; // status baru: in_progress / completed
  final VoidCallback onIngatkanPembeli;

  const KartuPesananPenjual({
    super.key,
    required this.pesanan,
    required this.onBukaDetail,
    required this.onUbahStatus,
    required this.onIngatkanPembeli,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.jarakInput),
      padding: const EdgeInsets.all(AppTheme.jarakTepi),
      decoration: BoxDecoration(
        color: AppTheme.warnaPermukaan,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.warnaLatarNetral),
        boxShadow: const [BoxShadow(color: AppTheme.warnaBayanganKartu, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: AppTheme.ikonMata, color: AppTheme.warnaJarak),
              const SizedBox(width: AppTheme.jarakLabel),
              Expanded(
                child: Text(
                  pesanan.namaPembeli ?? 'Pembeli',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: AppTheme.fontSedang, fontWeight: FontWeight.w700, color: AppTheme.warnaJudulKartu),
                ),
              ),
              StatusBadge(status: pesanan.status, label: pesanan.labelStatus),
            ],
          ),
          const SizedBox(height: AppTheme.jarakMini),
          Text(
            '${ListingModel.formatTanggal(pesanan.dibuatPada)}, ${ListingModel.formatJam(pesanan.dibuatPada)} WIB • ID: #${pesanan.id}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup),
          ),
          const SizedBox(height: AppTheme.jarakSedang),
          Row(
            children: [
              _Gambar(urlGambar: pesanan.urlGambar),
              const SizedBox(width: AppTheme.jarakSedang),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pesanan.namaProduk,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: AppTheme.fontSedang, fontWeight: FontWeight.w700, color: AppTheme.warnaJudulKartu),
                    ),
                    const SizedBox(height: AppTheme.jarakTipis),
                    Text('${pesanan.jumlah} unit', style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup)),
                    if (pesanan.kategori != null && pesanan.kategori!.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.jarakMini),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakLabel, vertical: AppTheme.jarakTipis),
                        decoration: BoxDecoration(color: AppTheme.warnaLatarNetral, borderRadius: BorderRadius.circular(AppTheme.jarakLabel)),
                        child: Text(
                          pesanan.kategori!,
                          style: const TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w600, color: AppTheme.warnaTeksSedang),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.jarakSedang),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Harga Satuan: ${ListingModel.formatRupiah(pesanan.hargaSatuan)}',
                  style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup),
                ),
              ),
              Text(
                ListingModel.formatRupiah(pesanan.totalHarga),
                style: const TextStyle(fontSize: AppTheme.fontSubjudul, fontWeight: FontWeight.w800, color: AppTheme.warnaNavy),
              ),
            ],
          ),
          if (pesanan.status == 'in_progress' && pesanan.alamatGudang != null) ...[
            const SizedBox(height: AppTheme.jarakKecil),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: AppTheme.ikonKecil, color: AppTheme.warnaJarak),
                const SizedBox(width: AppTheme.jarakMini),
                Expanded(
                  child: Text(
                    'Diambil di: ${pesanan.alamatGudang}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksSedang),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppTheme.jarakSedang),
          ..._tombolAksi(),
          TextButton(
            onPressed: onBukaDetail,
            child: const Text('Lihat Rincian Faktur & Bukti Transaksi'),
          ),
        ],
      ),
    );
  }

  // Tombol aksi per status (paid -> siapkan; in_progress -> konfirmasi + ingatkan).
  List<Widget> _tombolAksi() {
    if (pesanan.status == 'paid') {
      return [
        _TombolAksi(
          teks: 'Siapkan & Tandai Siap Diambil',
          ikon: Icons.inventory_rounded,
          warna: AppTheme.warnaUtama,
          onPressed: () => onUbahStatus('in_progress'),
        ),
      ];
    }
    if (pesanan.status == 'in_progress') {
      return [
        _TombolAksi(
          teks: 'Konfirmasi Telah Diambil',
          ikon: Icons.handshake_rounded,
          warna: AppTheme.warnaSisaAman,
          onPressed: () => onUbahStatus('completed'),
        ),
        const SizedBox(height: AppTheme.jarakKecil),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppTheme.ukuranTombolIkon),
            foregroundColor: AppTheme.warnaJarak,
            backgroundColor: AppTheme.warnaLatarInfo,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSedang)),
          ),
          onPressed: onIngatkanPembeli,
          icon: const Icon(Icons.notifications_active_outlined, size: AppTheme.ikonKecil),
          label: const Text('Ingatkan Pembeli untuk Ambil'),
        ),
      ];
    }
    return const [];
  }
}

class _TombolAksi extends StatelessWidget {
  final String teks;
  final IconData ikon;
  final Color warna;
  final VoidCallback onPressed;

  const _TombolAksi({required this.teks, required this.ikon, required this.warna, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppTheme.ukuranTombolIkon),
        backgroundColor: warna,
        foregroundColor: AppTheme.warnaPermukaan,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSedang)),
      ),
      onPressed: onPressed,
      icon: Icon(ikon, size: AppTheme.ikonMata),
      label: Text(teks),
    );
  }
}

class _Gambar extends StatelessWidget {
  final String? urlGambar;

  const _Gambar({required this.urlGambar});

  @override
  Widget build(BuildContext context) {
    const Widget cadangan = ColoredBox(
      color: AppTheme.warnaLatarNetral,
      child: Center(child: Icon(Icons.inventory_2_outlined, size: AppTheme.ikonSedang, color: AppTheme.warnaTeksRedup)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusSedang),
      child: SizedBox(
        width: AppTheme.gambarPesanan,
        height: AppTheme.gambarPesanan,
        child: (urlGambar == null || urlGambar!.isEmpty)
            ? cadangan
            : Image.network(urlGambar!, fit: BoxFit.contain, errorBuilder: (c, e, s) => cadangan),
      ),
    );
  }
}
