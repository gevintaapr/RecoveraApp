import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

// SensorService: mendeteksi HP digoyang (shake) untuk memuat ulang data.
// Satu objek per layar: layar memanggil mulaiDeteksiGoyang() di initState
// dan berhenti() di dispose() supaya sensor tidak terus menyala.
//
// CATATAN: Menggunakan sensors_plus (elemen di luar modul)
// Fungsi: membaca akselerometer HP.
// Alasan: shake-to-refresh butuh data gerakan HP; sensor tidak dibahas di Modul I–VIII.
// Cara kerja: userAccelerometerEventStream mengirim percepatan x, y, z (m/s²)
//         tanpa pengaruh gravitasi. Bila besar percepatan melewati ambang,
//         dianggap goyangan. Setelah satu goyangan ada jeda 2 detik
//         (dibandingkan dengan waktu goyangan terakhir, tanpa Timer) agar
//         satu kali goyang tidak memicu refresh berkali-kali.
class SensorService {
  static const double _ambangGoyang = 15; // m/s², goyangan tangan yang cukup kuat
  static const Duration _jedaAntarGoyang = Duration(seconds: 2);

  StreamSubscription<UserAccelerometerEvent>? _langganan;
  DateTime _waktuGoyangTerakhir = DateTime.fromMillisecondsSinceEpoch(0);

  // Sensor hanya ada di HP; di Chrome / Windows method ini diam saja.
  bool get _didukung =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  void mulaiDeteksiGoyang(VoidCallback onGoyang) {
    if (!_didukung) return;
    _langganan = userAccelerometerEventStream().listen(
      (UserAccelerometerEvent event) {
        final double besar = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        if (besar < _ambangGoyang) return;

        final DateTime sekarang = DateTime.now();
        if (sekarang.difference(_waktuGoyangTerakhir) < _jedaAntarGoyang) return;
        _waktuGoyangTerakhir = sekarang;
        onGoyang();
      },
      onError: (Object e) {
        // HP tanpa akselerometer: fitur goyang dilewati, aplikasi tetap jalan.
      },
      cancelOnError: true,
    );
  }

  // Wajib dipanggil di dispose() layar.
  void berhenti() {
    _langganan?.cancel();
    _langganan = null;
  }
}
