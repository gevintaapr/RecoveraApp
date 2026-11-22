import 'package:geolocator/geolocator.dart';

// LocationService: semua urusan lokasi (Modul VII, package geolocator).
// - ambilLokasiSaatIni(): cek GPS + izin, lalu ambil koordinat HP.
// - hitungJarakKm(): jarak garis lurus antara dua titik, dalam km.
// Screen tidak memanggil Geolocator langsung, selalu lewat sini.
class LocationService {
  // Lokasi terakhir yang berhasil diambil, disimpan di memori
  // supaya layar lain (mis. detail listing) bisa menghitung jarak
  // tanpa meminta GPS lagi.
  static Position? lokasiTerakhir;

  // Urutan sesuai Modul VII:
  // 1. GPS menyala?  2. Izin sudah diberikan? Bila belum, minta.  3. Ambil posisi.
  // Gagal -> Exception berisi pesan yang bisa langsung ditampilkan.
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
      throw Exception('Izin lokasi ditolak permanen. Aktifkan lewat Pengaturan HP.');
    }

    try {
      // timeLimit: jangan menunggu GPS lebih dari 10 detik.
      final Position posisi = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      lokasiTerakhir = posisi;
      return posisi;
    } catch (e) {
      // GPS lambat (mis. di dalam ruangan): pakai posisi terakhir yang diketahui HP.
      final Position? posisiLama = await Geolocator.getLastKnownPosition();
      if (posisiLama == null) {
        throw Exception('Lokasi belum bisa didapat. Coba lagi di tempat terbuka.');
      }
      lokasiTerakhir = posisiLama;
      return posisiLama;
    }
  }

  // Geolocator.distanceBetween menghasilkan meter -> dibagi 1000 jadi km.
  static double hitungJarakKm(
    double latAwal,
    double lngAwal,
    double latTujuan,
    double lngTujuan,
  ) {
    return Geolocator.distanceBetween(latAwal, lngAwal, latTujuan, lngTujuan) / 1000;
  }
}
