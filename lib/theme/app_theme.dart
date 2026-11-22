import 'package:flutter/material.dart';

// CATATAN: Menggunakan google_fonts (elemen di luar modul)
// Fungsi: memakai font "Inter", sama dengan desain Recovera lama.
// Alasan: Flutter bawaan hanya punya font Roboto; desain Recovera memakai Inter.
// Cara kerja: GoogleFonts.interTextTheme() membuat TextTheme berfont Inter;
// font diunduh sekali saat pertama tampil lalu disimpan di HP.
import 'package:google_fonts/google_fonts.dart';

// SATU-SATUNYA tempat warna, ukuran font, radius, dan jarak.
// Nilai disamakan dengan desain Recovera lama (../recovera/lib/core/theme).
// Ganti nilai di sini -> seluruh aplikasi ikut berubah.
class AppTheme {
  // Warna dasar Recovera (AppColors lama).
  static const Color warnaUtama = Color(0xFF0077B6); // primary
  static const Color warnaUtamaGelap = Color(0xFF005F92); // primaryDark
  static const Color warnaUtamaTerang = Color(0xFF006CA7); // primaryLight: bawah header auth
  static const Color warnaLabelInput = Color(0xFF475569); // slate-600: label di atas input
  static const Color warnaSekunder = Color(0xFF00B4D8); // secondary
  static const Color warnaAksenMuda = Color(0xFF90E0EF); // accent (gelombang belakang)
  static const Color warnaNavy = Color(0xFF03045E); // darkNavy: judul & teks utama
  static const Color warnaLatar = Color(0xFFF8FAFC); // canvasBg
  static const Color warnaPermukaan = Colors.white;
  static const Color warnaTeks = warnaNavy;
  static const Color warnaTeksRedup = Color(0xFF64748B); // slateText
  static const Color warnaTeksSedang = Color(0xFF475569);
  static const Color warnaGaris = Color(0xFFE2E8F0); // border
  static const Color warnaGarisTegas = Color(0xFFE2E8F0);

  // Status (AppColors lama + pelengkap untuk badge).
  static const Color warnaSukses = Color(0xFF10B981); // success
  static const Color warnaLatarSukses = Color(0xFFECFDF5); // successBg
  static const Color warnaGarisSukses = Color(0xFF6EE7B7); // successBorder
  static const Color warnaGalat = Color(0xFFEF4444); // error
  static const Color warnaBahaya = warnaGalat; // hati favorit
  static const Color warnaAksen = Color(0xFFF97316); // oranye diskon / peringatan
  static const Color warnaSisaHari = Color(0xFFD97706); // amber "Sisa X hari"
  static const Color warnaLatarInfo = Color(0xFFE0F2FE);
  static const Color warnaTeksInfo = Color(0xFF075985);
  static const Color warnaLatarPeringatan = Color(0xFFFFEDD5);
  static const Color warnaTeksPeringatan = Color(0xFF9A3412);
  static const Color warnaLatarBahaya = Color(0xFFFEF2F2);
  static const Color warnaLatarNetral = Color(0xFFF1F5F9);
  static const Color warnaGelombang = Color(0x7390E0EF); // accent 45%: gelombang belakang header

  // Sisa dari desain kaca; dipertahankan agar widget lama tetap jalan.
  static const Color warnaKaca = Color(0x29FFFFFF); // putih 16%
  static const Color warnaCahayaLogo = Color(0x66FFFFFF); // putih 40%: cahaya di belakang logo
  static const Color warnaGarisKaca = Color(0x59FFFFFF); // putih 35%
  static const Color warnaBarKaca = Colors.white;
  static const Color warnaBayangan = Color(0x260077B6); // bayangan biru tombol utama
  static const double blurKaca = 12;

  // Recovera lama memakai biru solid; "gradien" dibuat satu warna agar widget lama
  // yang memakainya tampil solid.
  static const LinearGradient gradienUtama = LinearGradient(colors: [warnaUtama, warnaUtama]);
  static const LinearGradient gradienHeader = LinearGradient(colors: [warnaUtama, warnaUtama]);
  static const LinearGradient gradienScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 0.45],
    colors: [Color(0x0003045E), Color(0xE603045E)],
  );

  // Skala font Recovera lama (textTheme Inter).
  static const double fontMini = 9;
  static const double fontInput = 12; // hint & label input
  static const double fontLabel = 10; // labelSmall
  static const double fontKecil = 11; // bodySmall
  static const double fontNormal = 13; // bodyMedium
  static const double fontSedang = 14; // titleMedium, tombol
  static const double fontSubjudul = 16; // judul AppBar
  static const double fontBesar = 22; // headlineMedium
  static const double fontJudul = 28; // headlineLarge
  static const double fontSambutan = 26; // "Welcome back!" di layar auth
  static const double fontLabelInput = 12; // label di atas PillTextField

  static const double jarakTipis = 2;
  static const double jarakMini = 4;
  static const double jarakLabel = 6; // padding & radius label kecil
  static const double jarakKecil = 8;
  static const double jarakSedang = 12;
  static const double jarakTepi = 16;
  static const double jarakBesar = 20;
  static const double jarakInput = 14; // padding vertikal input & tombol

  static const double radiusChip = 8;
  static const double radiusTombol = 12;
  static const double radius = 16; // kartu
  static const double radiusBesar = 20;
  static const double radiusKapsul = 50; // input & tombol kapsul

  static const double tinggiTombol = 48;
  static const double tinggiInput = 48;
  static const double ukuranTombolIkon = 44;
  static const double tinggiChip = 32;
  static const double ukuranTombolKecil = 32;
  static const double ukuranLingkaranLangkah = 28;
  static const double ikonKecil = 16;
  static const double ikonSedang = 20;
  static const double ikonMata = 18; // ikon tampilkan password
  static const double tandaValid = 26; // lingkaran centang email valid
  static const double ikonCentang = 14;
  static const double ikonLogo = 72;
  static const double logoHeader = 24; // logo kecil di samping tulisan Recovera
  static const double logoHeaderAuth = 96; // logo mark di header Login/Register
  static const double tombolHeader = 38; // tombol bulat di header biru (area ketuk 44)
  static const double jarakAuthSisi = 24; // padding kiri-kanan kartu putih auth
  static const double jarakAuthAtas = 64; // ruang kurva gelombang di atas kartu auth
  static const double gambarKartu = 84;
  static const double gambarDetail = 240;
  static const double tinggiGelombang = 28;
  static const double rasioKotakRingkasan = 1.6;

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
  static const TextStyle gayaJudul = TextStyle(
    fontSize: fontBesar,
    fontWeight: FontWeight.w700,
    color: warnaNavy,
    letterSpacing: -0.3,
  );
  static const TextStyle gayaSubjudul = TextStyle(
    fontSize: fontSedang,
    fontWeight: FontWeight.w600,
    color: warnaNavy,
  );
  static const TextStyle gayaTeks = TextStyle(fontSize: fontNormal, color: warnaNavy);
  static const TextStyle gayaTeksRedup = TextStyle(fontSize: fontNormal, color: warnaTeksRedup);
  static const TextStyle gayaLabelKapital = TextStyle(
    fontSize: fontLabel,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    color: warnaTeksRedup,
  );

  // Tema Material untuk GetMaterialApp (mengikuti AppTheme.light Recovera lama).
  static ThemeData get tema {
    final ThemeData dasar = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: warnaUtama,
        primary: warnaUtama,
        onPrimary: warnaPermukaan,
        secondary: warnaSekunder,
        surface: warnaLatar,
        onSurface: warnaNavy,
        error: warnaGalat,
      ),
      scaffoldBackgroundColor: warnaLatar,
    );
    final OutlineInputBorder garisInput = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusKapsul),
      borderSide: const BorderSide(color: warnaGaris),
    );
    final TextStyle gayaTombol = GoogleFonts.inter(fontSize: fontSedang, fontWeight: FontWeight.w700);
    final RoundedRectangleBorder bentukKapsul =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusKapsul));

    return dasar.copyWith(
      textTheme: GoogleFonts.interTextTheme(dasar.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(
            fontSize: fontJudul, fontWeight: FontWeight.w700, color: warnaNavy, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.inter(
            fontSize: fontBesar, fontWeight: FontWeight.w700, color: warnaNavy, letterSpacing: -0.3),
        // Recovera lama hampir selalu memakai w600-w700; teks biasa minimal w500
        // supaya tidak terlihat tipis.
        titleLarge: GoogleFonts.inter(fontSize: fontSubjudul, fontWeight: FontWeight.w700, color: warnaNavy),
        titleMedium: GoogleFonts.inter(fontSize: fontSedang, fontWeight: FontWeight.w700, color: warnaNavy),
        titleSmall: GoogleFonts.inter(fontSize: fontNormal, fontWeight: FontWeight.w600, color: warnaNavy),
        bodyLarge: GoogleFonts.inter(fontSize: fontSedang, fontWeight: FontWeight.w500, color: warnaNavy),
        bodyMedium: GoogleFonts.inter(fontSize: fontNormal, fontWeight: FontWeight.w500, color: warnaNavy),
        bodySmall: GoogleFonts.inter(fontSize: fontKecil, fontWeight: FontWeight.w500, color: warnaTeksRedup),
        labelLarge: GoogleFonts.inter(fontSize: fontSedang, fontWeight: FontWeight.w700),
        labelMedium: GoogleFonts.inter(fontSize: fontKecil, fontWeight: FontWeight.w600),
        labelSmall: GoogleFonts.inter(
            fontSize: fontLabel, fontWeight: FontWeight.w600, color: warnaTeksRedup, letterSpacing: 0.8),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: warnaUtama,
        foregroundColor: warnaPermukaan,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: fontSubjudul,
          fontWeight: FontWeight.w700,
          color: warnaPermukaan,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: warnaLatar,
        contentPadding: const EdgeInsets.symmetric(horizontal: jarakBesar, vertical: jarakInput),
        border: garisInput,
        enabledBorder: garisInput,
        focusedBorder: garisInput.copyWith(borderSide: const BorderSide(color: warnaUtama, width: 2)),
        errorBorder: garisInput.copyWith(borderSide: const BorderSide(color: warnaGalat)),
        hintStyle: GoogleFonts.inter(fontSize: fontInput, fontWeight: FontWeight.w500, color: warnaTeksRedup),
        labelStyle: GoogleFonts.inter(fontSize: fontInput, fontWeight: FontWeight.w500, color: warnaTeksRedup),
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: warnaUtama,
          foregroundColor: warnaPermukaan,
          elevation: 4,
          shadowColor: warnaUtama.withValues(alpha: 0.35),
          shape: bentukKapsul,
          padding: const EdgeInsets.symmetric(vertical: jarakInput, horizontal: jarakBesar + jarakMini),
          textStyle: gayaTombol,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: warnaUtama,
          shape: bentukKapsul,
          textStyle: gayaTombol,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: warnaUtama,
          side: const BorderSide(color: warnaUtama),
          shape: bentukKapsul,
          textStyle: gayaTombol,
        ),
      ),
      chipTheme: dasar.chipTheme.copyWith(
        backgroundColor: warnaPermukaan,
        side: const BorderSide(color: warnaGaris),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusKapsul)),
        labelStyle: GoogleFonts.inter(fontSize: fontKecil, color: warnaNavy),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      dividerTheme: const DividerThemeData(color: warnaGaris, thickness: 1, space: 1),
    );
  }
}
