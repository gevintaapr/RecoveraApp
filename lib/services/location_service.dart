import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// LocationService: semua urusan lokasi (Modul VII, package geolocator).
// - ambilLokasiSaatIni(): cek GPS + izin, lalu ambil koordinat HP.
// - hitungJarakKm(): jarak garis lurus antara dua titik, dalam km.
// - ambilNamaKota(): reverse geocoding dari koordinat ke nama kota.
// Hasil pilihan lokasi dari layar peta (koordinat + nama kota hasil reverse geocoding).
class TitikLokasi {
  final double lat;
  final double lng;
  final String kota;

  const TitikLokasi({required this.lat, required this.lng, required this.kota});
}

class LocationService {
  static Position? lokasiTerakhir;

  static Future<Position> ambilLokasiSaatIni() async {
    final bool gpsMenyala = await Geolocator.isLocationServiceEnabled();
    if (!gpsMenyala) {
      throw Exception('GPS mati. Nyalakan lokasi di HP terlebih dahulu.');
    }

    LocationPermission izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) {
      izin = await Geolocator.requestPermission();
    }
    if (izin == LocationPermission.denied) {
      throw Exception('Izin lokasi ditolak.');
    }
    if (izin == LocationPermission.deniedForever) {
      throw Exception(
          'Izin lokasi ditolak permanen. Aktifkan lewat Pengaturan HP.');
    }

    try {
      final Position posisi = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      lokasiTerakhir = posisi;
      return posisi;
    } catch (e) {
      final Position? posisiLama = await Geolocator.getLastKnownPosition();
      if (posisiLama == null) {
        throw Exception(
            'Lokasi belum bisa didapat. Coba lagi di tempat terbuka.');
      }
      lokasiTerakhir = posisiLama;
      return posisiLama;
    }
  }

  static double hitungJarakKm(
    double latAwal,
    double lngAwal,
    double latTujuan,
    double lngTujuan,
  ) {
    return Geolocator.distanceBetween(latAwal, lngAwal, latTujuan, lngTujuan) /
        1000;
  }

  // Format tampilan lokasi usaha: "Nama Kota (lat, lng)", misal "Sleman (-7.7058, 110.6053)".
  static String formatLokasi(String namaKota, double lat, double lng) {
    return '$namaKota (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
  }

  // Reverse geocoding: mencari nama kota dari koordinat latitude & longitude.
  // 1. Mencoba reverse geocoding OpenStreetMap (Nominatim).
  // 2. Jika offline / request gagal: estimasi kota terdekat di Indonesia.
  static Future<String> ambilNamaKota(double lat, double lng) async {
    try {
      final Uri uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=10&addressdetails=1',
      );
      final http.Response response = await http
          .get(uri, headers: {'User-Agent': 'RecoveraApp/2.0'})
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic>? address =
            data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final String? nama = address['city'] as String? ??
              address['city_district'] as String? ??
              address['town'] as String? ??
              address['municipality'] as String? ??
              address['county'] as String? ??
              address['state'] as String?;
          if (nama != null && nama.trim().isNotEmpty) {
            return nama.trim();
          }
        }
      }
    } catch (_) {}

    return _estimasiKotaTerdekat(lat, lng);
  }

  static String _estimasiKotaTerdekat(double lat, double lng) {
    final Map<String, List<double>> daftarKota = {
      'Jakarta Barat': [-6.1683, 106.7588],
      'Jakarta Selatan': [-6.2615, 106.8106],
      'Jakarta Pusat': [-6.1754, 106.8272],
      'Jakarta Timur': [-6.2250, 106.9004],
      'Jakarta Utara': [-6.1384, 106.8640],
      'Tangerang': [-6.1783, 106.6319],
      'Tangerang Selatan': [-6.2888, 106.7179],
      'Bekasi': [-6.2383, 106.9756],
      'Depok': [-6.4025, 106.7942],
      'Bogor': [-6.5971, 106.8060],
      'Bandung': [-6.9175, 107.6191],
      'Semarang': [-6.9667, 110.4167],
      'Yogyakarta': [-7.7956, 110.3695],
      'Surakarta': [-7.5755, 110.8243],
      'Surabaya': [-7.2575, 112.7521],
      'Malang': [-7.9666, 112.6326],
      'Denpasar': [-8.6705, 115.2126],
      'Medan': [3.5952, 98.6722],
      'Palembang': [-2.9761, 104.7754],
      'Bandar Lampung': [-5.4292, 105.2625],
      'Makassar': [-5.1477, 119.4327],
      'Balikpapan': [-1.2654, 116.8312],
      'Samarinda': [-0.5022, 117.1537],
      'Banjarmasin': [-3.3194, 114.5908],
      'Pontianak': [-0.0263, 109.3425],
      'Manado': [1.4748, 124.8421],
    };

    String kotaTerdekat = 'Jakarta';
    double jarakMinimum = double.infinity;

    daftarKota.forEach((nama, titik) {
      final double jarak = hitungJarakKm(lat, lng, titik[0], titik[1]);
      if (jarak < jarakMinimum) {
        jarakMinimum = jarak;
        kotaTerdekat = nama;
      }
    });

    return kotaTerdekat;
  }
}
