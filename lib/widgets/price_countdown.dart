import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Hitung mundur ke penurunan harga berikutnya (lelang Belanda), berdetak tiap detik.
// Waktu tujuan = next_drop_at dari server. Saat mencapai nol, onHargaTurun
// dipanggil supaya layar mengambil harga baru DARI SERVER (harga tidak
// dihitung di HP).
class PriceCountdown extends StatefulWidget {
  final DateTime waktuTurun;
  final VoidCallback? onHargaTurun;
  final bool ringkas; // true = chip kecil untuk kartu katalog
  final String? teksHargaMinimum; // panel besar: tampil di sisi kanan bila diisi

  const PriceCountdown({
    super.key,
    required this.waktuTurun,
    this.onHargaTurun,
    this.ringkas = false,
    this.teksHargaMinimum,
  });

  @override
  State<PriceCountdown> createState() => _PriceCountdownState();
}

class _PriceCountdownState extends State<PriceCountdown> {
  Timer? _timer;
  Duration _sisaWaktu = Duration.zero;

  @override
  void initState() {
    super.initState();
    _mulai();
  }

  // Data baru dari server (waktu turun berikutnya berubah) -> mulai ulang.
  @override
  void didUpdateWidget(PriceCountdown lama) {
    super.didUpdateWidget(lama);
    if (lama.waktuTurun != widget.waktuTurun) _mulai();
  }

  // CATATAN: Menggunakan Timer (elemen di luar modul)
  // Fungsi: memperbarui sisa waktu di layar setiap 1 detik.
  // Alasan: hitung mundur lelang harus bergerak; FutureBuilder/setState biasa
  //         hanya berjalan saat ada aksi pengguna.
  // Cara kerja: Timer.periodic memanggil setState tiap detik dengan sisa waktu
  //         baru. Saat sisa waktu habis, Timer dihentikan dan onHargaTurun
  //         dipanggil. Timer dibatalkan di dispose() agar tidak bocor.
  void _mulai() {
    _timer?.cancel();
    _hitungSisa();
    if (_sisaWaktu == Duration.zero) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(_hitungSisa);
      if (_sisaWaktu == Duration.zero) {
        timer.cancel();
        widget.onHargaTurun?.call();
      }
    });
  }

  void _hitungSisa() {
    final Duration sisa = widget.waktuTurun.difference(DateTime.now());
    _sisaWaktu = sisa.isNegative ? Duration.zero : sisa;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 3725 detik -> "01:02:05"
  String get _teksSisa {
    final String jam = _sisaWaktu.inHours.toString().padLeft(2, '0');
    final String menit = (_sisaWaktu.inMinutes % 60).toString().padLeft(2, '0');
    final String detik = (_sisaWaktu.inSeconds % 60).toString().padLeft(2, '0');
    return '$jam:$menit:$detik';
  }

  @override
  Widget build(BuildContext context) {
    final bool habis = _sisaWaktu == Duration.zero;

    if (widget.ringkas) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakMini, vertical: AppTheme.jarakMini / 4),
        decoration: BoxDecoration(
          color: AppTheme.warnaLatarInfo,
          borderRadius: BorderRadius.circular(AppTheme.radiusChip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule, size: AppTheme.fontLabel, color: AppTheme.warnaTeksInfo),
            const SizedBox(width: AppTheme.jarakMini),
            Text(
              habis ? 'memperbarui...' : 'turun $_teksSisa',
              maxLines: 1,
              style: const TextStyle(
                fontSize: AppTheme.fontLabel,
                fontWeight: FontWeight.w700,
                color: AppTheme.warnaTeksInfo,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
    }

    // Panel besar di detail: gradien navy, semua teks putih (lolos kontras di seluruh gradien).
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.jarakSedang, vertical: AppTheme.jarakSedang),
      decoration: BoxDecoration(
        gradient: AppTheme.gradienHeader,
        borderRadius: BorderRadius.circular(AppTheme.radiusTombol),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Harga turun berikutnya dalam',
                  style: TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaPermukaan),
                ),
                Text(
                  habis ? 'Memperbarui...' : _teksSisa,
                  style: const TextStyle(
                    fontSize: AppTheme.fontJudul,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: AppTheme.warnaPermukaan,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          if (widget.teksHargaMinimum != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Harga minimum',
                  style: TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaPermukaan),
                ),
                Text(
                  widget.teksHargaMinimum!,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSubjudul,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.warnaPermukaan,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
