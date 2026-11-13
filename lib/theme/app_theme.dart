import 'package:flutter/material.dart';

// SATU-SATUNYA tempat warna, ukuran font, radius, dan jarak.
// Versi sederhana sementara; nanti diganti sesuai desain final.
// Ganti nilai di sini -> seluruh aplikasi ikut berubah.
class AppTheme {
  // ===== WARNA =====
  static const Color warnaUtama = Color(0xFF2E7D32); // hijau
  static const Color warnaLatar = Color(0xFFF7F7F7);
  static const Color warnaPermukaan = Colors.white;
  static const Color warnaTeks = Color(0xFF212121);
  static const Color warnaTeksRedup = Color(0xFF757575);
  static const Color warnaGalat = Color(0xFFC62828);
  static const Color warnaAksen = Color(0xFFEF6C00); // oranye: diskon, peringatan
  static const Color warnaGaris = Color(0xFFE0E0E0);

  // ===== UKURAN FONT =====
  static const double fontJudul = 24;
  static const double fontSubjudul = 18;
  static const double fontNormal = 14;
  static const double fontKecil = 12;

  // ===== JARAK & RADIUS =====
  static const double jarakKecil = 8;
  static const double jarakSedang = 16;
  static const double jarakBesar = 24;
  static const double radius = 12;
  static const double tinggiTombol = 48;
  static const double ikonLogo = 72;
  static const double gambarKartu = 88; // gambar kecil di kartu listing
  static const double gambarDetail = 220; // gambar besar di halaman detail

  // ===== GAYA TEKS HARGA =====
  static const TextStyle gayaHarga = TextStyle(
    fontSize: fontSubjudul,
    fontWeight: FontWeight.bold,
    color: warnaUtama,
  );
  static const TextStyle gayaHargaCoret = TextStyle(
    fontSize: fontKecil,
    color: warnaTeksRedup,
    decoration: TextDecoration.lineThrough,
  );

  // ===== GAYA TEKS =====
  static const TextStyle gayaJudul = TextStyle(
    fontSize: fontJudul,
    fontWeight: FontWeight.bold,
    color: warnaTeks,
  );
  static const TextStyle gayaSubjudul = TextStyle(
    fontSize: fontSubjudul,
    fontWeight: FontWeight.w600,
    color: warnaTeks,
  );
  static const TextStyle gayaTeksRedup = TextStyle(
    fontSize: fontNormal,
    color: warnaTeksRedup,
  );

  // ===== TEMA MATERIAL (dipakai di MaterialApp) =====
  static ThemeData get tema {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: warnaUtama, error: warnaGalat),
      scaffoldBackgroundColor: warnaLatar,
      appBarTheme: const AppBarTheme(
        backgroundColor: warnaPermukaan,
        foregroundColor: warnaTeks,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: warnaPermukaan,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}
