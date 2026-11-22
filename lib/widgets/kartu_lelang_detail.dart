import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../theme/app_theme.dart';
import 'price_countdown.dart';

// Isi seksi "Mekanisme Dutch Auction" di Detail produk (versi lama, data asli):
// kotak hitung mundur bergradien -> progres penurunan harga -> kotak jadwal
// (turun berikutnya & lelang berakhir).
class KartuLelangDetail extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onHargaTurun;

  const KartuLelangDetail({super.key, required this.listing, required this.onHargaTurun});

  // Seberapa jauh harga sudah turun dari harga mulai menuju harga minimum (0..1).
  // Hanya rasio tampilan dari tiga angka server, bukan menghitung harga baru.
  double? get _progresTurun {
    final double? mulai = listing.hargaMulai;
    if (mulai == null || mulai <= listing.hargaMinimum) return null;
    return ((mulai - listing.hargaSekarang) / (mulai - listing.hargaMinimum)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? turun = listing.waktuTurunBerikutnya;
    final double? progres = _progresTurun;
    final String teksMinimum = ListingModel.formatRupiah(listing.hargaMinimum);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (turun == null)
          Container(
            padding: const EdgeInsets.all(AppTheme.radiusSedang),
            decoration: BoxDecoration(color: AppTheme.warnaLatarNetral, borderRadius: BorderRadius.circular(AppTheme.radiusChip)),
            child: Text('Harga sudah di batas terendah ($teksMinimum)', style: AppTheme.gayaTeksRedup),
          )
        else
          PriceCountdown(waktuTurun: turun, onHargaTurun: onHargaTurun, teksHargaMinimum: teksMinimum),
        if (progres != null) ...[
          const SizedBox(height: AppTheme.jarakKecil),
          Row(
            children: [
              const Expanded(
                child: Text('Progres Penurunan Harga', style: TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup)),
              ),
              Text(
                '${(progres * 100).round()}% menuju harga minimum',
                style: const TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w600, color: AppTheme.warnaUtama),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.jarakMini),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.jarakMini),
            child: LinearProgressIndicator(
              value: progres,
              minHeight: AppTheme.ukuranTitik,
              backgroundColor: AppTheme.warnaGaris,
              color: AppTheme.warnaUtama,
            ),
          ),
        ],
        const SizedBox(height: AppTheme.radiusSedang),
        Container(
          padding: const EdgeInsets.all(AppTheme.radiusSedang),
          decoration: BoxDecoration(
            color: AppTheme.warnaLatar,
            borderRadius: BorderRadius.circular(AppTheme.radiusChip),
            border: Border.all(color: AppTheme.warnaGaris),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Jadwal Lelang & Batas Pengambilan',
                style: TextStyle(fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w700, color: AppTheme.warnaJudulKartu),
              ),
              const SizedBox(height: AppTheme.jarakKecil),
              Row(
                children: [
                  Expanded(
                    child: _KotakJadwal(
                      warnaTitik: AppTheme.warnaTitikJadwal,
                      label: 'Turun Berikutnya',
                      nilai: turun == null ? '-' : '${ListingModel.formatJam(turun)} WIB',
                    ),
                  ),
                  const SizedBox(width: AppTheme.jarakKecil),
                  Expanded(
                    child: _KotakJadwal(
                      warnaTitik: AppTheme.warnaPitaDiskon,
                      label: 'Lelang Berakhir',
                      nilai: '${ListingModel.formatTanggal(listing.lelangBerakhir)}, ${ListingModel.formatJam(listing.lelangBerakhir)}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KotakJadwal extends StatelessWidget {
  final Color warnaTitik;
  final String label;
  final String nilai;

  const _KotakJadwal({required this.warnaTitik, required this.label, required this.nilai});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.jarakKecil),
      decoration: BoxDecoration(
        color: AppTheme.warnaPermukaan,
        borderRadius: BorderRadius.circular(AppTheme.jarakLabel),
        border: Border.all(color: AppTheme.warnaGaris),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: AppTheme.ukuranTitik, height: AppTheme.ukuranTitik, decoration: BoxDecoration(color: warnaTitik, shape: BoxShape.circle)),
              const SizedBox(width: AppTheme.jarakMini),
              Text(label, style: const TextStyle(fontSize: AppTheme.fontMini, color: AppTheme.warnaTeksRedup)),
            ],
          ),
          const SizedBox(height: AppTheme.jarakTipis),
          Text(nilai, style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w600, color: AppTheme.warnaJudulKartu)),
        ],
      ),
    );
  }
}
