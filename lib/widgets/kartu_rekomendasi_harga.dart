import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../models/price_advice_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'baris_info.dart';
import 'chip_lembut.dart';
import 'dialog_memuat.dart';
import 'kartu_bagian.dart';

// Kartu hasil rekomendasi harga dari server (LightGBM atau rumus cadangan).
// Kartunya hanya menampilkan; tombol "Terbitkan" ada di layar pemanggil
// dan memakai fungsi terbitkanDenganKonfirmasi di bawah.
class KartuRekomendasiHarga extends StatelessWidget {
  final PriceAdviceModel saran;
  final ListingModel draft;

  const KartuRekomendasiHarga({super.key, required this.saran, required this.draft});

  @override
  Widget build(BuildContext context) {
    final bool adaRentang = saran.batasBawah != null && saran.batasAtas != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Kartu utama diberi garis biru: ini keputusan yang sedang diminta dari penjual.
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusBesar),
            side: const BorderSide(color: AppTheme.warnaUtama, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.jarakSedang),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ChipLembut(
                      // Sumber ditulis jujur: model atau rumus cadangan dari server.
                      teks: saran.dariModelAi ? 'Rekomendasi AI · LightGBM' : 'Rekomendasi rumus',
                      warnaLatar: AppTheme.warnaUtama,
                      warnaTeks: AppTheme.warnaPermukaan,
                    ),
                    const Spacer(),
                    ChipLembut(
                      teks: 'Diskon ${saran.persenDiskon.round()}%',
                      warnaLatar: AppTheme.warnaLatarSukses,
                      warnaTeks: AppTheme.warnaSukses,
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.jarakKecil),
                const Text('Harga awal lelang', style: TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup)),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: AppTheme.jarakKecil,
                  children: [
                    Text(
                      ListingModel.formatRupiah(saran.hargaSaran),
                      style: AppTheme.gayaJudul.copyWith(color: AppTheme.warnaUtama),
                    ),
                    Text('/${draft.satuan}', style: AppTheme.gayaTeksRedup),
                    Text(ListingModel.formatRupiah(draft.hargaNormal), style: AppTheme.gayaHargaCoret),
                  ],
                ),
                if (saran.alasan.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.jarakKecil),
                  Text(saran.alasan, style: AppTheme.gayaTeksRedup),
                ],
                if (saran.perluPeringatan) ...[
                  const SizedBox(height: AppTheme.jarakKecil),
                  const ChipLembut(
                    teks: 'Di luar rentang wajar, akan diminta konfirmasi saat terbit',
                    warnaLatar: AppTheme.warnaLatarPeringatan,
                    warnaTeks: AppTheme.warnaTeksPeringatan,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (adaRentang) ...[
          const SizedBox(height: AppTheme.jarakKecil),
          KartuBagian(
            judul: 'Rentang harga yang disarankan',
            children: [
              _BatangRentang(bawah: saran.batasBawah!, atas: saran.batasAtas!, harga: saran.hargaSaran),
            ],
          ),
        ],
        const SizedBox(height: AppTheme.jarakKecil),
        KartuBagian(
          judul: 'Aturan lelang Belanda',
          children: [
            BarisInfo(label: 'Harga minimum', nilai: ListingModel.formatRupiah(draft.hargaMinimum)),
            BarisInfo(label: 'Stok', nilai: '${draft.stok} ${draft.satuan}'),
            BarisInfo(label: 'Kedaluwarsa', nilai: ListingModel.formatTanggal(draft.tanggalKedaluwarsa)),
            const SizedBox(height: AppTheme.jarakKecil),
            const Text(
              'Setelah terbit, harga turun bertahap otomatis dan tidak pernah di bawah harga minimum.',
              style: TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup),
            ),
          ],
        ),
      ],
    );
  }
}

// Batang batas bawah - batas atas dari server, dengan titik di posisi harga saran.
class _BatangRentang extends StatelessWidget {
  final double bawah;
  final double atas;
  final double harga;

  const _BatangRentang({required this.bawah, required this.atas, required this.harga});

  @override
  Widget build(BuildContext context) {
    final double posisi = atas <= bawah ? 0.5 : ((harga - bawah) / (atas - bawah)).clamp(0.0, 1.0);
    const double titik = AppTheme.ikonKecil;
    return Column(
      children: [
        SizedBox(
          height: titik,
          child: LayoutBuilder(
            builder: (context, batas) => Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: AppTheme.jarakMini,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradienUtama,
                    borderRadius: BorderRadius.circular(AppTheme.radiusKapsul),
                  ),
                ),
                Positioned(
                  left: (batas.maxWidth - titik) * posisi,
                  child: Container(
                    width: titik,
                    height: titik,
                    decoration: BoxDecoration(
                      color: AppTheme.warnaPermukaan,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.warnaUtama, width: 3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppTheme.jarakKecil),
        Row(
          children: [
            Expanded(child: _labelBatas(ListingModel.formatRupiah(bawah), 'Batas bawah', CrossAxisAlignment.start)),
            _labelBatas(ListingModel.formatRupiah(atas), 'Batas atas', CrossAxisAlignment.end),
          ],
        ),
      ],
    );
  }

  Widget _labelBatas(String nilai, String keterangan, CrossAxisAlignment rata) {
    return Column(
      crossAxisAlignment: rata,
      children: [
        Text(nilai, style: const TextStyle(fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w800)),
        Text(keterangan, style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup)),
      ],
    );
  }
}

// Alur "Terbitkan" yang sama untuk form listing dan detail listing penjual:
// konfirmasi (bila harga di luar rentang) -> dialog loading -> API ->
// notifikasi "Listing terbit". Mengembalikan true bila berhasil terbit.
// Pesan galat dilempar ulang supaya layar pemanggil yang menanganinya
// (termasuk "Sesi berakhir" -> kembali ke Login).
Future<bool> terbitkanDenganKonfirmasi(
  BuildContext context, {
  required int idListing,
  required PriceAdviceModel saran,
}) async {
  bool setujuiPeringatan = false;
  if (saran.perluPeringatan) {
    final bool? setuju = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Harga di luar rentang wajar'),
        content: const Text('Tetap terbitkan dengan harga ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Terbitkan')),
        ],
      ),
    );
    if (setuju != true || !context.mounted) return false;
    setujuiPeringatan = true;
  }

  tampilkanDialogMemuat(context, pesan: 'Menerbitkan listing...');
  final ListingModel listing;
  try {
    listing = await ApiService.terbitkanListing(
      idListing,
      setujuiPeringatan: setujuiPeringatan,
    );
  } finally {
    // Dialog loading ditutup baik berhasil maupun gagal.
    if (context.mounted) Navigator.pop(context);
  }
  // Pop-up langsung (immediate notification, Modul VII).
  await NotificationService().showInstantNotification(
    id: NotificationService.idListingTerbit(listing.id),
    title: 'Listing terbit',
    body: '${listing.namaProduk} sudah tampil di katalog pembeli',
  );
  return true;
}
