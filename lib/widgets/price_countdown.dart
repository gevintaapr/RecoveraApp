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
  final bool ringkas; // true = teks kecil untuk kartu katalog

  const PriceCountdown({
    super.key,
    required this.waktuTurun,
    this.onHargaTurun,
    this.ringkas = false,
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
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_down, size: AppTheme.fontNormal, color: AppTheme.warnaAksen),
          const SizedBox(width: AppTheme.jarakKecil / 2),
          Text(
            habis ? 'Memperbarui harga...' : 'Turun dalam $_teksSisa',
            style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaAksen),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.jarakSedang),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.warnaAksen),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppTheme.warnaAksen),
          const SizedBox(width: AppTheme.jarakKecil),
          const Expanded(child: Text('Harga turun berikutnya dalam', style: AppTheme.gayaTeksRedup)),
          Text(
            habis ? 'Memperbarui...' : _teksSisa,
            style: AppTheme.gayaSubjudul.copyWith(color: AppTheme.warnaAksen),
          ),
        ],
      ),
    );
  }
}
