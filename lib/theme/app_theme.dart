import 'package:flutter/material.dart';

// CATATAN: Menggunakan google_fonts (elemen di luar modul)
// Fungsi: memakai font "Plus Jakarta Sans" sesuai desain Recovera Ocean Glass.
// Alasan: Flutter bawaan hanya punya font Roboto; desain meminta font lain.
// Cara kerja: GoogleFonts.plusJakartaSansTextTheme() membuat TextTheme berfont
// Plus Jakarta Sans; font diunduh sekali saat pertama tampil lalu disimpan di HP.
import 'package:google_fonts/google_fonts.dart';

// SATU-SATUNYA tempat warna, ukuran font, radius, dan jarak.
// Desain: "Recovera Ocean Glass" (biru laut + efek kaca).
// Ganti nilai di sini -> seluruh aplikasi ikut berubah.
class AppTheme {
  // Warna dasar. Biru laut dipilih karena tema "Ocean Glass": tenang, dingin, segar.
  static const Color warnaUtama = Color(0xFF0077B6);
  static const Color warnaUtamaGelap = Color(0xFF023E8A); // ujung gelap gradien
  static const Color warnaNavy = Color(0xFF03045E); // pangkal gradien header
  // Cyan hanya untuk aksen tanpa teks di atasnya: putih di atas cyan cuma 2.46:1.
  static const Color warnaSekunder = Color(0xFF00B4D8);
  static const Color warnaLatar = Color(0xFFF5F8FB);
  static const Color warnaPermukaan = Colors.white;
  static const Color warnaTeks = Color(0xFF0B1B3A);
  static const Color warnaTeksRedup = Color(0xFF5B6B80); // 5.1:1 di warnaLatar (WCAG AA)
  static const Color warnaTeksSedang = Color(0xFF475569);
  static const Color warnaGaris = Color(0xFFE6EDF3);
  static const Color warnaGarisTegas = Color(0xFFDCE6EF);

  // Warna status. Selalu dipasangkan dengan teks/ikon, tidak pernah warna saja.
  static const Color warnaAksen = Color(0xFFC2410C); // diskon, peringatan
  static const Color warnaSukses = Color(0xFF047857);
  static const Color warnaLatarSukses = Color(0xFFE6F6EE);
  static const Color warnaLatarInfo = Color(0xFFE0F2FE); // juga latar item nav aktif
  static const Color warnaTeksInfo = Color(0xFF075985); // teks di atas warnaLatarInfo
  static const Color warnaBahaya = Color(0xFFE11D48); // hati favorit
  static const Color warnaGalat = warnaBahaya; // pesan error, tombol keluar
  static const Color warnaSisaHari = Color(0xFFB45309); // amber "Sisa X hari"
  static const Color warnaLatarPeringatan = Color(0xFFFFEDD5); // badge menunggu/draft
  static const Color warnaTeksPeringatan = Color(0xFF9A3412); // 6.4:1 di atas latarnya
  static const Color warnaLatarBahaya = Color(0xFFFFF1F2); // latar ikon hati terisi
  static const Color warnaLatarNetral = Color(0xFFF1F5F9); // tombol kecil, tab segmen
  static const Color warnaGelombang = Color(0x7300B4D8); // cyan 45%, lapis gelombang header

  // Kaca dipakai paling banyak di 2 elemen per layar (tombol ikon header, bar bawah).
  static const Color warnaKaca = Color(0x29FFFFFF); // putih 16%
  static const Color warnaGarisKaca = Color(0x59FFFFFF); // putih 35%
  static const Color warnaBarKaca = Color(0xD9FFFFFF); // putih 85%: bottom nav, bar bawah
  static const Color warnaBayangan = Color(0x1403045E); // navy 8%, hanya untuk bar yang melayang
  static const double blurKaca = 12;

  // Gradien 135 derajat. Titik paling terang #0077B6, jadi teks putih lolos 4.87:1 di
  // seluruh area. Hanya dipakai di header bergelombang dan tombol utama.
  static const LinearGradient gradienUtama = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warnaUtama, warnaUtamaGelap],
  );
  // Lapisan gelap di bawah foto detail: transparan ke navy 90%. Teks putih hanya
  // duduk di bagian pekat (mulai 45%), jadi tetap terbaca di atas foto terang.
  static const LinearGradient gradienScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 0.45],
    colors: [Color(0x0003045E), Color(0xE603045E)],
  );
  static const LinearGradient gradienHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warnaNavy, warnaUtamaGelap, warnaUtama],
  );

  static const double fontMini = 9.5; // pita diskon, badge
  static const double fontLabel = 10.5; // chip, label kecil
  static const double fontKecil = 11.5; // keterangan
  static const double fontNormal = 12.5; // isi
  static const double fontSedang = 13; // nama produk, tombol
  static const double fontSubjudul = 15;
  static const double fontBesar = 18; // harga besar, judul header
  static const double fontJudul = 24;

  // Jarak rapat: aplikasi kerja B2B, banyak data per layar.
  static const double jarakMini = 4;
  static const double jarakKecil = 8; // antar-elemen
  static const double jarakSedang = 12; // padding kartu
  static const double jarakTepi = 14; // tepi layar
  static const double jarakBesar = 16;

  static const double radiusChip = 8;
  static const double radiusTombol = 12;
  static const double radius = 14; // kartu
  static const double radiusBesar = 16; // kartu besar, bar bawah
  static const double radiusKapsul = 999; // input, search

  static const double tinggiTombol = 46;
  static const double tinggiInput = 44;
  static const double ukuranTombolIkon = 44; // area ketuk minimal 44
  static const double tinggiChip = 32; // area ketuk tetap 44 lewat padding
  static const double ukuranTombolKecil = 32; // hati di kartu, tombol +/-
  static const double ukuranLingkaranLangkah = 26; // stepper upload
  static const double ikonKecil = 16;
  static const double ikonSedang = 20;
  static const double ikonLogo = 72;
  static const double gambarKartu = 84; // foto kartu listing versi daftar
  static const double gambarDetail = 240; // foto besar di halaman detail
  static const double tinggiGelombang = 28; // gelombang di bawah header
  static const double rasioKotakRingkasan = 1.6; // lebar : tinggi kotak angka di Dasbor

  static const TextStyle gayaHarga = TextStyle(
    fontSize: fontSubjudul,
    fontWeight: FontWeight.w800,
    color: warnaUtama,
  );
  static const TextStyle gayaHargaCoret = TextStyle(
    fontSize: fontKecil,
    color: warnaTeksRedup,
    decoration: TextDecoration.lineThrough,
  );

  // Tanpa fontFamily: font ikut tema (Plus Jakarta Sans) lewat DefaultTextStyle.
  static const TextStyle gayaJudul = TextStyle(
    fontSize: fontJudul,
    fontWeight: FontWeight.w800,
    color: warnaTeks,
  );
  static const TextStyle gayaSubjudul = TextStyle(
    fontSize: fontSubjudul,
    fontWeight: FontWeight.w700,
    color: warnaTeks,
  );
  static const TextStyle gayaTeks = TextStyle(
    fontSize: fontNormal,
    color: warnaTeks,
  );
  static const TextStyle gayaTeksRedup = TextStyle(
    fontSize: fontNormal,
    color: warnaTeksRedup,
  );
  static const TextStyle gayaLabelKapital = TextStyle(
    fontSize: fontMini,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: warnaTeksRedup,
  ); // nama penjual KAPITAL kecil di kartu

  // Tema Material untuk GetMaterialApp.
  static ThemeData get tema {
    final ThemeData dasar = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: warnaUtama,
        primary: warnaUtama,
        secondary: warnaSekunder,
        error: warnaGalat,
        surface: warnaPermukaan,
      ),
      scaffoldBackgroundColor: warnaLatar,
    );
    final OutlineInputBorder garisInput = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusKapsul),
      borderSide: const BorderSide(color: warnaGarisTegas),
    );
    return dasar.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(dasar.textTheme)
          .apply(bodyColor: warnaTeks, displayColor: warnaTeks),
      appBarTheme: AppBarTheme(
        backgroundColor: warnaLatar,
        foregroundColor: warnaTeks,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: fontBesar,
          fontWeight: FontWeight.w800,
          color: warnaTeks,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: warnaPermukaan,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: jarakBesar,
          vertical: jarakSedang,
        ),
        border: garisInput,
        enabledBorder: garisInput,
        focusedBorder: garisInput.copyWith(
          borderSide: const BorderSide(color: warnaUtama, width: 1.5),
        ),
        errorBorder: garisInput.copyWith(
          borderSide: const BorderSide(color: warnaGalat),
        ),
        labelStyle: const TextStyle(fontSize: fontNormal, color: warnaTeksRedup),
        hintStyle: const TextStyle(fontSize: fontNormal, color: warnaTeksRedup),
      ),
      cardTheme: CardThemeData(
        color: warnaPermukaan,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: warnaGaris),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: warnaUtama,
          minimumSize: const Size.fromHeight(tinggiTombol),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusTombol)),
          textStyle: const TextStyle(fontSize: fontSedang, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: warnaUtama,
          side: const BorderSide(color: warnaGarisTegas),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusTombol)),
          textStyle: const TextStyle(fontSize: fontSedang, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: dasar.chipTheme.copyWith(
        backgroundColor: warnaPermukaan,
        side: const BorderSide(color: warnaGaris),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusChip)),
        labelStyle: const TextStyle(fontSize: fontLabel, color: warnaTeks),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusTombol)),
      ),
      dividerTheme: const DividerThemeData(color: warnaGaris, thickness: 1, space: 1),
    );
  }
}
