import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../models/price_advice_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'baris_info.dart';
import 'dialog_memuat.dart';

// Kartu hasil rekomendasi harga dari server (LightGBM atau rumus cadangan).
// Kartunya hanya menampilkan; tombol "Terbitkan" ada di layar pemanggil
// dan memakai fungsi terbitkanDenganKonfirmasi di bawah.
class KartuRekomendasiHarga extends StatelessWidget {
  final PriceAdviceModel saran;
  final ListingModel draft;

  const KartuRekomendasiHarga({super.key, required this.saran, required this.draft});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.jarakSedang),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppTheme.warnaUtama),
                const SizedBox(width: AppTheme.jarakKecil),
                const Expanded(child: Text('Rekomendasi Harga', style: AppTheme.gayaSubjudul)),
                Chip(
                  label: Text(saran.dariModelAi ? 'Model AI' : 'Rumus cadangan'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.jarakKecil),
            Text('Harga awal lelang', style: AppTheme.gayaTeksRedup),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppTheme.jarakKecil,
              runSpacing: 4,
              children: [
                Text(ListingModel.formatRupiah(saran.hargaSaran),
                    style: AppTheme.gayaJudul.copyWith(color: AppTheme.warnaUtama)),
                Text(ListingModel.formatRupiah(draft.hargaNormal), style: AppTheme.gayaHargaCoret),
                Text('-${saran.persenDiskon.round()}%',
                    style: const TextStyle(color: AppTheme.warnaAksen, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: AppTheme.jarakBesar),
            BarisInfo(label: 'Harga minimum', nilai: ListingModel.formatRupiah(draft.hargaMinimum)),
            if (saran.batasBawah != null && saran.batasAtas != null)
              BarisInfo(
                label: 'Rentang wajar',
                nilai: '${ListingModel.formatRupiah(saran.batasBawah!)} – '
                    '${ListingModel.formatRupiah(saran.batasAtas!)}',
              ),
            BarisInfo(label: 'Stok', nilai: '${draft.stok} ${draft.satuan}'),
            BarisInfo(label: 'Kedaluwarsa', nilai: ListingModel.formatTanggal(draft.tanggalKedaluwarsa)),
            if (saran.alasan.isNotEmpty) ...[
              const SizedBox(height: AppTheme.jarakKecil),
              Text(saran.alasan, style: AppTheme.gayaTeksRedup),
            ],
            const SizedBox(height: AppTheme.jarakKecil),
            const Text(
              'Setelah terbit, harga turun bertahap otomatis (lelang Belanda) '
              'dan tidak pernah di bawah harga minimum.',
              style: TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaTeksRedup),
            ),
            if (saran.perluPeringatan)
              const Padding(
                padding: EdgeInsets.only(top: AppTheme.jarakKecil),
                child: Text(
                  'Harga awal di luar rentang wajar. Anda akan diminta konfirmasi saat menerbitkan.',
                  style: TextStyle(color: AppTheme.warnaAksen),
                ),
              ),
          ],
        ),
      ),
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
