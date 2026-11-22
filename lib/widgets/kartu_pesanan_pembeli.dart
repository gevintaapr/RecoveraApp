import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'dialog_memuat.dart';
import 'status_badge.dart';

// Kartu pesanan pembeli di Riwayat (_buildBuyerOrderCard Recovera lama):
// penjual + status, tanggal & ID, produk, Total Tagihan, lalu aksi sesuai status:
// - paid        : "Hubungi Seller" (POST remind-seller) & "Rincian Faktur"
// - in_progress : kotak lokasi ambil + tombol buka detail
// - completed   : kotak hijau "Pesanan selesai diambil"
class KartuPesananPembeli extends StatelessWidget {
  final OrderModel pesanan;
  final VoidCallback onBukaDetail;

  const KartuPesananPembeli({super.key, required this.pesanan, required this.onBukaDetail});

  Future<void> _hubungiPenjual(BuildContext context) async {
    tampilkanDialogMemuat(context, pesan: 'Mengirim pengingat ke penjual...');
    try {
      await ApiService.ingatkanPenjual(pesanan.id);
      if (!context.mounted) return;
      Navigator.pop(context); // tutup dialog loading
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengingat dikirim kepada penjual.')));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppTheme.warnaGalat),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.jarakInput),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: onBukaDetail,
          child: Ink(
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
                    Expanded(
                      child: Text(
                        pesanan.namaPenjual ?? '-',
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
                          Text(
                            '${pesanan.jumlah} × ${ListingModel.formatRupiah(pesanan.hargaSatuan)}',
                            style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup),
                          ),
                          if (pesanan.kategori != null) ...[
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
                    const Expanded(
                      child: Text('Total Tagihan:', style: TextStyle(fontSize: AppTheme.fontInput, color: AppTheme.warnaTeksRedup)),
                    ),
                    Text(
                      ListingModel.formatRupiah(pesanan.totalHarga),
                      style: const TextStyle(fontSize: AppTheme.fontSubjudul, fontWeight: FontWeight.w800, color: AppTheme.warnaNavy),
                    ),
                  ],
                ),
                ..._aksiSesuaiStatus(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _aksiSesuaiStatus(BuildContext context) {
    final ButtonStyle gayaGaris = OutlinedButton.styleFrom(
      foregroundColor: AppTheme.warnaUtama,
      side: const BorderSide(color: AppTheme.warnaGarisCari),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSedang)),
      minimumSize: const Size.fromHeight(AppTheme.ukuranTombolIkon),
      textStyle: const TextStyle(fontSize: AppTheme.fontInput, fontWeight: FontWeight.w600),
    );
    switch (pesanan.status) {
      case 'paid':
        return [
          const SizedBox(height: AppTheme.jarakSedang),
          Row(
            children: [
              Expanded(child: OutlinedButton(style: gayaGaris, onPressed: () => _hubungiPenjual(context), child: const Text('Hubungi Seller'))),
              const SizedBox(width: AppTheme.radiusSedang),
              Expanded(
                child: OutlinedButton(
                  style: gayaGaris.copyWith(foregroundColor: const WidgetStatePropertyAll(AppTheme.warnaTeksSedang)),
                  onPressed: onBukaDetail,
                  child: const Text('Rincian Faktur'),
                ),
              ),
            ],
          ),
        ];
      case 'in_progress':
        return [
          const SizedBox(height: AppTheme.radiusSedang),
          _KotakInfo(
            ikon: Icons.location_on_outlined,
            teks: 'Siap diambil di: ${pesanan.alamatGudang ?? '-'}',
            latar: AppTheme.warnaLatarKedaluwarsa,
            warna: AppTheme.warnaSisaSedang,
          ),
          const SizedBox(height: AppTheme.jarakSedang),
          SizedBox(
            height: AppTheme.ukuranTombolIkon,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSedang)),
                textStyle: const TextStyle(fontSize: AppTheme.fontInput, fontWeight: FontWeight.w700),
              ),
              icon: const Icon(Icons.location_on_rounded, size: AppTheme.ikonMata),
              label: const Text('Petunjuk Lokasi & Pengambilan Gudang'),
              onPressed: onBukaDetail,
            ),
          ),
        ];
      case 'completed':
        return [
          const SizedBox(height: AppTheme.radiusSedang),
          const _KotakInfo(
            ikon: Icons.check_circle_rounded,
            teks: 'Pesanan selesai diambil',
            latar: AppTheme.warnaLatarStok,
            warna: AppTheme.warnaSisaAman,
          ),
        ];
      default:
        return const [];
    }
  }
}

class _KotakInfo extends StatelessWidget {
  final IconData ikon;
  final String teks;
  final Color latar;
  final Color warna;

  const _KotakInfo({required this.ikon, required this.teks, required this.latar, required this.warna});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.radiusSedang),
      decoration: BoxDecoration(color: latar, borderRadius: BorderRadius.circular(AppTheme.radiusSedang)),
      child: Row(
        children: [
          Icon(ikon, color: warna, size: AppTheme.ikonMata),
          const SizedBox(width: AppTheme.jarakKecil),
          Expanded(child: Text(teks, style: TextStyle(fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w700, color: warna))),
        ],
      ),
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
      child: Center(child: Icon(Icons.inventory_2_outlined, color: AppTheme.warnaTeksRedup)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusSedang),
      child: SizedBox(
        width: AppTheme.gambarPesanan,
        height: AppTheme.gambarPesanan,
        child: (urlGambar == null || urlGambar!.isEmpty)
            ? cadangan
            : Image.network(urlGambar!, fit: BoxFit.cover, errorBuilder: (c, e, s) => cadangan),
      ),
    );
  }
}
